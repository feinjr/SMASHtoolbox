%% object creation and basic visualization
moments=[0 1^2; 0 2^2];
object=SMASH.MonteCarlo.Cloud(moments);

plot(object.Data(:,1),object.Data(:,2),'.');
axis equal;
xlabel('x');
ylabel('y');

%% visualization
close all;
view(object);

object=configure(object,'NumberBins',20);
view(object);

view(object,'','points');

view(object,'histogram','ellipse');

[hd,hc]=view(object,'density','density');

%% summary and confidence regions
summarize(object);

confidence(object);

%% saving for later
filename='myclouds.sda';
if exist(filename,'file')
    delete(filename);
end
SMASH.FileAccess.writeFile(filename,'my first cloud',object);

SMASH.FileAccess.probeFile(filename)
previous=SMASH.FileAccess.readFile(filename,'sda','my first cloud');

%% what does skewness do?
clear all;
close all;

N=1e6;
value=0.5;
object1=SMASH.MonteCarlo.Cloud([0 1 0  0],[],N);
object2=SMASH.MonteCarlo.Cloud([0 1 +value 0],[],N);
object3=SMASH.MonteCarlo.Cloud([0 1 -value 0],[],N);

bins=linspace(-10,10,100);
y1=hist(object1.Data,bins);
y2=hist(object2.Data,bins);
y3=hist(object3.Data,bins);

plot(bins,y1,bins,y2,bins,y3);
xlim([-5 5]);

%% what does kurtosis do?
clear all;
close all;

N=1e6;
object1=SMASH.MonteCarlo.Cloud([0 1 0  0],[],N);
object2=SMASH.MonteCarlo.Cloud([0 1 0 +10],[],N);
object3=SMASH.MonteCarlo.Cloud([0 1 0 -1],[],N);

bins=linspace(-10,10,100);
y1=hist(object1.Data,bins);
y2=hist(object2.Data,bins);
y3=hist(object3.Data,bins);

plot(bins,y1,bins,y2,bins,y3);
%set(gca,'YScale','log')