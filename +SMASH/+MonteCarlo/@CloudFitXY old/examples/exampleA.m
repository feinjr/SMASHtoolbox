%% create CloudFitXY object
object=SMASH.MonteCarlo.CloudFitXY();

x=[0 1 2 3 4];
y=x;
dx=0.10;
dy=dx;
object=add(object,[x(:) y(:)],[dx dy],0);

%% linear fit
clc
%xf=linspace(-1,6,50);
xf=[-1 6];
tic; result=analyze(object,'polynomial',[1 0],xf); toc;

%% display result
clf
view(object,'cloud')
box on;

a=summarize(result);
[~,fit]=polynomial(a(:,1),xf);
line(xf,fit,'Color','k');
summarize(result);
confidence(result);
