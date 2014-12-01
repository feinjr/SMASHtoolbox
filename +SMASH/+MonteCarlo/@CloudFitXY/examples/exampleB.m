%% create CloudFitXY object
x=[0 1 2 3 4];
y=x.^2;
dx=0.10;
dy=dx;
%object=add(object,[x(:) y(:)],[dx dy],0);
object=SMASH.MonteCarlo.CloudFitXY([x(:) y(:)],[dx dy],0);

%% quadratic fit
clc;
xf=linspace(-1,6,50);
tic; result=analyze(object,'polynomial',[1 0 0],xf); toc;
%tic; result=analyze(object,'polynomial',[0 1 0],xf); toc;

clf
view(object,'cloud')
box on;

a=summarize(result);
[~,fit]=polynomial(a(:,1),xf);
line(xf,fit,'Color','k');
summarize(result);
confidence(result);