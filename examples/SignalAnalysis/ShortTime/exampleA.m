% generate data
time=-200:(1/20):1000; % ns
amplitude=(1+5*(time/time(end)));
amplitude(time<0)=1;
phase=2*pi*(1*time)+2*pi*rand(1);
index=(time>=0);
phase(index)=phase(index)+1*2*pi*(time(index).^2/max(time(index)));
signal=amplitude.*cos(phase)+randn(size(time));
object=SMASH.SignalAnalysis.ShortTime(time,signal);
view(object);

%% set up and analyze partitions
object=partition(object,'Duration',[50 10]);

result=analyze(object,@(local) [sqrt(2*mean(local.Data.^2)); mean(local.Data)]);
h=view(result,[],gca);
legend(h,'Extimated amplitude','Estimated baseline','Location','northwest');
title('20 ns analysis blocks')

%% switch over to STFT
object=SMASH.SignalAnalysis.STFT(object);

object=partition(object,'Duration',[20 0.5]);
result=analyze(object);
view(result);

%% adaptive example

