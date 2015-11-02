%% generate object
x=[0 1 2];
y=[0 1 2.5];
variance=2*0.1^2;
dx2=[0.1 0.01 0.1].^2;
dy2=variance-dx2;

xtable=[x(:) dx2(:)];
ytable=[y(:) dy2(:)];
correlation=[0 0 -0.75];
Npoints=1e4;

object=SMASH.MonteCarlo.CloudFit2D(xtable,ytable,correlation,Npoints);
view(object);
object.ViewOptions.CloudMode='ellipses';
object.ViewOptions.CloudColor='k';
view(object,gca);

%% draw cloud points
view(object);

temp=drawPoints(object);
line(temp(:,1),temp(:,2),'Marker','*','LineStyle','none');

%% set up model
xb=[min(x) max(x)];
yb=[min(y) max(y)];

target=@(p,xb,yb) [xb(:) p(1)*xb(:)+p(2)];
object=setupModel(object,target,[1 0],[],xb,yb);
object.ViewOptions.CloudColor='r';
view(object);

%% small-scale Monte Carlo analysis
N=10;
tic;
%profile on;
[result,new]=analyze(object,N);
%profile report;
%profile off;
duration=toc;
fprintf('Total time : %#.3g seconds \n',duration);
fprintf('Time per iteration : %#.3g seconds\n',duration/N);
view(result);

summarize(result);
investigate(result);

view(new);

%% large-scale Monte Carlo analysis
N=1000;
tic;
[result,new]=analyze(object,N);
duration=toc;
fprintf('Total time : %#.3g seconds \n',duration);
fprintf('Time per iteration : %#.3g seconds\n',duration/N);
fprintf('Time per calculation : %#.3g seconds\n',...
    duration/N/object.NumberClouds/object.NumberDraws/(size(object.Model.Curve,1)-1));

summarize(result);
investigate(result);

view(new);