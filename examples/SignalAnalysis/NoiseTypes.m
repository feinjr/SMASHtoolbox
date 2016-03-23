%% set up time base
t=0:(1/80):100;
t=t(:);

%% generate simple noise
amplitude=1;

noiseA=amplitude*randn(size(t));

%% Nyquist fraction noise
figure;
noiseB=SMASH.SignalAnalysis.NoiseSignal(t);
noiseB.Amplitude=amplitude;
noiseB=defineTransfer(noiseB,'fraction',0.25);
noiseB=generate(noiseB);

subplot(2,1,1);
plot(t,noiseA,'r');
view(noiseB,'measurement',gca);
xlabel('Time');
ylabel('Signal');
title('Nyquist fraction noise');

subplot(2,1,2);
cla;
view(noiseB,'autocorrelation',gca);
box on;
xlabel('Delay');
ylabel('Correlation');
xlim([0 1]);

%% bandwidth noise
figure;

noiseB=SMASH.SignalAnalysis.NoiseSignal(t);
noiseB.Amplitude=amplitude;
noiseB=defineTransfer(noiseB,'bandwidth',5);
noiseB=generate(noiseB);

subplot(2,1,1);
plot(t,noiseA,'r');
view(noiseB,'measurement',gca);
xlabel('Time');
ylabel('Signal');
title('Low pass noise');

subplot(2,1,2);
cla;
view(noiseB,'autocorrelation',gca);
box on;
xlabel('Delay');
ylabel('Correlation');
xlim([0 1]);