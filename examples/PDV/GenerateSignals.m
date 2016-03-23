function GenerateSignals()

%% base velocity history
T=1/80; % ns
time=-50:T:150; % ns
velocity=zeros(size(time)); % m/s

t1=30;
v1=1000;
index=(time>0);
velocity(index)=time(index)*v1/t1;

index=(time>30) & (time<40);
velocity(index)=1100;

v2=1200;
t2=75;
index=(time>=40) & (time<t2);
velocity(index)=v2;

index=(time>=t2);
velocity(index)=(v2+100)*exp(-(time(index)-t2)/50);

velocity=velocity-100*exp(-(time-10).^2/(2*1^2));

plot(time,velocity);

time=time*1e-9; % convert ns to s
data=[time(:) velocity(:)];
filename='VelocityProfile.txt';
if exist(filename,'file')
    delete(filename)
end
SMASH.FileAccess.writeFile(filename,data,'%+#10.6e %+#10.6g\n',...
    {'Time (s) Velocity (m/s)'});

% should this use the NoiseSignal class?

%% exampleA : velocity history only
params.wavelength=1550e-9;
params.fshift=1e9;
params.coupling='AC';
loadSMASH -program fringen
signalA=fringen('PDV',filename,params); 
signalA=signalA/(std(signalA)*sqrt(2)); % normalized amplitude to 1

noise=randn(size(signalA));
kernel=-11:11;
kernel=exp(-kernel.^2/(2*3^2));
noise=conv2(noise,kernel,'same');
sigma=0.20;
noise=noise*(sigma/std(noise));
signalA=signalA+noise;

N=numel(signalA);
N2=pow2(nextpow2(N));
transform=fft(signalA,N2);
T=T*1e-9;
f=(0:N2/2)/(N2*T);
f=[f -f(end-1:-1:2)];
profile=1./(1+(f/25e9).^30); % Butterworth filter
transform=transform.*profile(:);
signalA=ifft(transform,'symmetric');
signalA=signalA(1:N);

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