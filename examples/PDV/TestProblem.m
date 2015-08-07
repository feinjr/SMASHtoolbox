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
SMASH.FileAccess.writeFile('VelocityInput.txt',data,'%#g %#g\n',...
    {'Time (s) Velocity (m/s)'});

%% create PDV signal
params.wavelength=1550e-9;
params.fshift=1e9;
params.coupling='AC';
%params.noise_fraction=0.10; % crude noise generator
loadSMASH -program fringen
signal=fringen('PDV','VelocityInput.txt',params); 

noise=randn(size(signal));
noise=conv2(noise,ones(5,1),'same');
noise=noise*(0.20/std(noise));
signal=signal+noise;

%% create PDV object
object=SMASH.Velocimetry.PDV(time,signal);
object=configure(object,'Window','Hann');
object=preview(object,'Duration',[5e-9 1e-9]);
%preview(object);

object=configure(object,'Duration',[5e-9 1e-9]);

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
object=analyze(object,'power');
result1=split(object.Frequency{1});

result1=scale(result1,1e9);
result1=result1/1e9;

%% sinusoid analysis
object=analyze(object,'sinusoid');
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