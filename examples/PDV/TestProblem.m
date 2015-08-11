%% create velocity history
T=1/80; % ns
time=-20:T:200;
velocity=zeros(size(time)); % m/s

t1=50;
v1=2000;
index=(time>0);
velocity(index)=time(index)*v1/t1;

v2=2500;
t2=100;
index=(time>=t1) & (time<t2);
velocity(index)=v2;

index=(time>=t2);
velocity(index)=v2*exp(-(time(index)-t2)/50);

%plot(time,velocity);
time=time*1e-9; % convert ns to s
data=[time(:) velocity(:)];
filename='VelocityInput.txt';
if exist(filename,'file')
    delete(filename)
end
SMASH.FileAccess.writeFile(filename,data,'%#g %#g\n',...
    {'Time (s) Velocity (m/s)'});

%% create PDV signal
params.wavelength=1550e-9;
params.fshift=1e9;
params.coupling='AC';
%params.noise_fraction=0.10; % crude noise generator
loadSMASH -program fringen
signal=fringen('PDV',filename,params); 

noise=randn(size(signal));
kernel=-11:11;
kernel=exp(-kernel.^2/(2*3^2));
noise=conv2(noise,kernel,'same');
sigma=0.20;
noise=noise*(sigma/std(noise));
signal=signal+noise;

%% create PDV object
object=SMASH.Velocimetry.PDV(time,signal);
%object=configure(object,'Window','Hann');
object=configure(object,'Window','boxcar');
object=preview(object,'Duration',[5e-9 1e-9]);
preview(object);

duration=5e-9;
skip=0.2e-9;
%skip=0.1e-9;
%object=configure(object,'Duration',[5e-9 1e-9]);
%object=configure(object,'Duration',[5e-9 0.1e-9]);

%% define bounds
manual=false;
if manual
    object=bound(object);
else
    previous=SMASH.FileAccess.readFile(...
        'PreviousBoundary.sda','sda','manual selection');
    object=bound(object,'add',previous);
end

%% power analysis
object=configure(object,'Window','Hann','Duration',[duration*(0.58/0.34) skip]);

object=analyze(object,'power');
result1=split(object.Frequency{1});

result1=scale(result1,1e9);
result1=result1/1e9;

%% sinusoid analysis
object=configure(object,'Duration',[duration skip]);

tic;
object=analyze(object,'sinusoid');
toc;
result2=split(object.Frequency{1});

result2=scale(result2,1e9);
result2=result2/1e9;

%% compare results
figure;
result1.GraphicOptions.LineColor='b';
result2.GraphicOptions.LineColor='r';

view(result1,gca);
view(result2,gca);
xlabel('Time (ns)');
ylabel('Beat frequency (GHz)');

beat=params.fshift+2*velocity/params.wavelength;
line(time*1e9,beat/1e9,'Color','k');

legend('centroid','sinusoid','source');

%%
fs=(numel(time)-1)/(time(end)-time(1));
tau=duration;
uncertainty=sqrt(6/fs/tau^3)*sigma/pi;
uncertainty=uncertainty/1e9;
fprintf('Limiting uncertainty: %#.1g GHz\n',uncertainty);

temp=regrid(result1,result2.Grid);
view(temp-result2);
xlabel('Time (ns)')
ylabel('Difference (GHz)');

line(xlim,repmat(uncertainty,[1 2]),'Color','k','LineStyle','--');
line(xlim,repmat(-uncertainty,[1 2]),'Color','k','LineStyle','--');