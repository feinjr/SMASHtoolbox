%% create object and add two data point
object=SMASH.MonteCarlo.CurveFit2D();

% xmean ymean xvar yvar
table=[];
dx=1e-6;
dy=0.05;
table(1,:)=[0 0 dx^2 dy^2];
table(2,:)=[1 1 dx^2 dy^2];
object=add(object,table);

view(object);

%% analytic solution
x=table(:,1);
y=table(:,2);
yvar=mean(table(:,4));

N=numel(x);
Delta=N*sum(x.^2)-(sum(x))^2;
A=(sum(x.^2)*sum(y)-sum(x)*sum(x.*y))/Delta;
B=(N*sum(x.*y)-sum(x)*sum(y))/Delta;
Avar=yvar*sum(x.^2)/Delta;
Bvar=yvar*N/Delta;

fprintf('Analytic soluction\n');
fprintf('\tslope    : %#-.4g (%#-.2g variance)\n',B,Bvar);
fprintf('\tintercept: %#-.4g (%#-.2g variance)\n',A,Avar);

%% unconstrained optimizations
result={};
object=define(object,@LineModel,[1.0 0.0],[]);

object.AssumeNormal=true;
tic;
object=optimize(object);
time(1)=toc;
view(object);
result{1}=object.Parameter;

% this optimization starts where previous one left off
object.AssumeNormal=false;
tic;
object=optimize(object);
time(2)=toc;
view(object);
result{2}=object.Parameter;

label={'Normal analysis' 'General analysis'};
for n=1:2
    fprintf('%s:\n',label{n});
    fprintf('\t Fit parameters: ');
    fprintf('%.5g ',result{n});
    fprintf('\n');
    fprintf('\tOptimization time: %g seconds\n',time(n));
end

%% Monte Carlo analysis
iterations=50;
object.AssumeNormal=true;
tic;
result=analyze(object,iterations);
time=toc;
view(result);
fprintf('Monte Carlo analysis with normal assumption\n');
summarize(result);
fprintf('\tAnalysis time: %g seconds\n\n',time);

object.AssumeNormal=false;
tic;
result=analyze(object,iterations);
time=toc;
view(result);
fprintf('Monte Carlo analysis without normal assumption\n');
summarize(result);
fprintf('\tAnalysis time: %g seconds\n\n',time);

