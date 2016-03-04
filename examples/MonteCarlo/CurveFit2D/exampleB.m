%% create object and add two data point
object=SMASH.MonteCarlo.CurveFit2D(...
    'GridPoints',1000,...
    'ContourFraction',[0.25 0.50 0.75 0.95 0.99],...
    'SmoothFactor',4);

% xmean ymean xvar yvar xycorr xskew yskew
table=[];
table(1,:)=[0 0 0.01 0.01 0 0.0 0];
table(2,:)=[1 1 0.01 0.01 0 0.75 0];
object=add(object,table);

view(object);

%% unconstrained optimizations
object=define(object,@LineModel,[0.5 1],[]);

object.AssumeNormal=true;
tic;
object=optimize(object);
time(1)=toc;
view(object);
result{1}=object.Parameter;

% note that this optimization starts where previous one left off
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

%% Monte Carlo analysis assuming normal distributions
iterations=100;
object.AssumeNormal=true;
tic;
result=analyze(object,iterations);
toc
view(result);

%% Monte Carlo analysis without assuming normal distributions
object.AssumeNormal=false;
tic;
result=analyze(object,iterations);
toc
view(result);