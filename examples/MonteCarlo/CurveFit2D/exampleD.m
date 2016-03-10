%%
% This example shows a line fit between three measurements.  One of these
% measurements has significantly higher uncertainty than the other two, so
% the fit largely misses the low quality point.
%

%% create object and add measurements

object=SMASH.MonteCarlo.CurveFit2D();

% xmean ymean xvar yva
table=[];
table(1,:)=[0 0 1e-12 0.05^2];
table(2,:)=[0.5 0.5 1e-12 0.05^2];
table(3,:)=[1 0.1 1e-12 0.2^2];
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

%% parameter uncertainty
fprintf('Analyzing parameters...');
tic;
object.AssumeNormal=true;
result=analyze(object,1000);
summarize(result);
verify(result,1000,0.90);
toc;
fprintf('done!\n');