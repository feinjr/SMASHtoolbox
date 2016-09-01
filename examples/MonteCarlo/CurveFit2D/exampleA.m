%%
% This example demonstrates a line fit between two measurements. The
% measurements have similar normal uncertainties in the vertical direction
% and neglibile uncertainty in the horizontal direction.
%
% Maximum likelihood optimization with normal and generaly density analysis
% yields similar model parameters in this example.  Both are consistent
% with the analytical result.
%

%% create object and add two measurements
object=SMASH.MonteCarlo.CurveFit2D();

% xmean ymean xvar yvar
table=[];
dx=1e-6;
dy=0.10;
table(1,:)=[0 0 dx^2 dy^2];
table(2,:)=[1 1 dx^2 dy^2];
object=add(object,table);

view(object);

%% unconstrained optimizations
AnalyticLineFit(table(:,1),table(:,2),sqrt(table(:,4)));

figure;
result={};
object=define(object,@LineModel,[0.5 0.0],[]);

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

%%
result=analyze(object,5000);
summarize(result);