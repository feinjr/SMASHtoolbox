%%
% This example demonstrates a line fit between two measurements. The
% measurements have similar normal uncertainties in the horizontal and
% vertical directions.  Uncertainty in the second measurement is skewed
% along the vertical direction.
%
% Maximum likelihood optimization with normal and generaly density analysis
% do NOT yeld similar model parameters in this example.  General analysis
% draws the fit towards the second point's peak density, accounting for the
% skewness of this point.  Normal analysis and the analytic result overlook
% this detail
%

%% create object and add two measurements
object=SMASH.MonteCarlo.CurveFit2D();

% xmean ymean xvar yvar xycorr xskew yskew
table=[];
dx=0.05;
dy=0.05;
table(1,:)=[0 0 dx^2 dy^2 0 0 0];
table(2,:)=[1 1 dx^2 dy^2 0 0 0.75];
object=add(object,table);

view(object);

%% unconstrained optimizations
AnalyticLineFit(table(:,1),table(:,2),sqrt(table(:,4)));

figure;
result={};
object=define(object,@LineModel,[1.0 0.0],[]);

ha(1)=subplot(2,1,1); box on; 
text('Units','normalized','Position',[1 1],...
    'HorizontalAlignment','right','VerticalAlignment','bottom',...
    'String','Normal density ');
object.AssumeNormal=true;
tic;
object=optimize(object);
time(1)=toc;
view(object,ha(1));
result{1}=object.Parameter;

% this optimization starts where previous one left off
ha(2)=subplot(2,1,2); box on;
text('Units','normalized','Position',[1 1],...
    'HorizontalAlignment','right','VerticalAlignment','bottom',...
    'String','General density ');
object.AssumeNormal=false;
tic;
object=optimize(object);
time(2)=toc;
view(object,ha(2));
result{2}=object.Parameter;

label={'Normal analysis' 'General analysis'};
for n=1:2
    fprintf('%s:\n',label{n});
    fprintf('\t Fit parameters: ');
    fprintf('%.5g ',result{n});
    fprintf('\n');
    fprintf('\tOptimization time: %g seconds\n',time(n));
end

linkaxes(ha,'xy');

%% Monte Carlo analysis
result=analyze(object,1000);