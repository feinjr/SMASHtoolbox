%%
% This example shows a two-piece line fit to a set of measurements that
% initially increase to a maximum and then decrease.  A Monte Carlo
% analysis is used to assess unceratinty of the fit parameters, including
% the break point bewtween the two linear sections.

%% create object and add measurement
object=SMASH.MonteCarlo.CurveFit2D('ContourFraction',0.1);

% xmean ymean xvar yvar
table=[];
table(end+1,:)=[0.00 0.00];
table(end+1,:)=[0.20 0.25];
table(end+1,:)=[0.45 0.40];
table(end+1,:)=[0.60 0.45];
table(end+1,:)=[0.75 0.25];
table(end+1,:)=[1.00 -0.01];
table(:,3)=0.05^2;
table(:,4)=0.05^2;
object=add(object,table);

view(object);

%%
figure;
result={};
object=define(object,@UpDownLine,[1.0 0.0 0.4 -1.0],[]);

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

%% parameter uncertainty
tic;
object.AssumeNormal=true;
result=analyze(object,50);
summarize(result);
verify(result,1000,0.90);
toc;