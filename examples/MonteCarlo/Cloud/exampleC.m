%% define cloud
moments=[10 1^2];
object=SMASH.MonteCarlo.Cloud(moments);

view(object,'density','ellipse');

%% transform cloud 
close all
clc
new=transform(object,@transformC1);
view(new,'density','points');
summarize(new);

x=xlim;
x=linspace(x(1),x(2),1000);
result=summarize(new);
x0=result(1);
sigma2=result(2);
Px=exp(-(x-x0).^2/(2*sigma2))/sqrt(2*pi*sigma2);
line(x,Px);
legend('Cloud density','Normal density');

%% transform cloud 
close all;
clc
new=transform(object,@transformC2);
view(new,'density','points');
summarize(new);

x=xlim;
x=linspace(x(1),x(2),1000);
result=summarize(new);
x0=result(1);
sigma2=result(2);
Px=exp(-(x-x0).^2/(2*sigma2))/sqrt(2*pi*sigma2);
line(x,Px);
legend('Cloud density','Normal density');