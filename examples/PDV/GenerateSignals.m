function GenerateSignals()

%% base velocity history
T=1/80; % ns
time=-20:T:150; % ns
velocity=zeros(size(time)); % m/s

t1=50;
v1=1000;
index=(time>0);
velocity(index)=time(index)*v1/t1;

v2=1200;
t2=75;
index=(time>=t1) & (time<t2);
velocity(index)=v2;

index=(time>=t2);
velocity(index)=(v2+100)*exp(-(time(index)-t2)/50);

velocity=velocity-100*exp(-(time-25).^2/(2*1^2));

%plot(time,velocity);
%return

time=time*1e-9; % convert ns to s
data=[time(:) velocity(:)];
filename='VelocityProfile.txt';
if exist(filename,'file')
    delete(filename)
end
SMASH.FileAccess.writeFile(filename,data,'%+#10.6e %+#10.6g\n',...
    {'Time (s) Velocity (m/s)'});

%% exampleA : velocity history only
params.wavelength=1550e-9;
params.fshift=1e9;
params.coupling='AC';
%params.noise_fraction=0.10; % crude noise generator
loadSMASH -program fringen
signalA=fringen('PDV',filename,params); 

noise=randn(size(signalA));
kernel=-11:11;
kernel=exp(-kernel.^2/(2*3^2));
noise=conv2(noise,kernel,'same');
sigma=0.20;
noise=noise*(sigma/std(noise));
signalA=signalA+noise;

data=[time(:) signalA(:)];
filename='exampleA.txt';
if exist(filename,'file')
    delete(filename)
end
SMASH.FileAccess.writeFile(filename,data,'%#+10.6e %#+10.4g\n',...
    {'Time (s) Signal (arg)'});

%% exampleB

%% 

end