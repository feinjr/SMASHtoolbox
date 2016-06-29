% generate data
time=-200:(1/80):1000; % ns
amplitude=(1+5*(time/time(end)));
amplitude(time<0)=1;
phase=2*pi*(0.1*time)+2*pi*rand(1);
signal=amplitude.*cos(phase)+randn(size(time));
object=SMASH.SignalAnalysis.ShortTime(time,signal);
view(object);

%% set up and analyze partitions
%object=partition(object,'Duration',[10 0.5]);
object=partition(object,'Duration',[10 20]);

result=analyze(object,@(x,y) [sqrt(2*mean(y.^2)); mean(y)]);
h=view(result,[],gca);
legend(h,'Extimated amplitude','Estimated baseline','Location','northwest');
title('20 ns analysis blocks')

%% adaptive example

