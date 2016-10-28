% Calibration of a linear Us-up fit to Al Hugoniot data. Data is seperated
% into lower and upper sets to give better predictive calculations


%% Parse the hugoniot data
data = dlmread('Al_GunHugData-C.dat');

up = data(:,1);
dup = data(:,2);
Us = data(:,3);
dUs = data(:,4);

[~,I] = sort(up); up = up(I); dup = dup(I); Us = Us(I); dUs = dUs(I);

break1 = 0.8; break2 = 2.6;
range1 = find(up < break1); 
range2 = find(up >= break1 & up <= break2); 
range3 = find(up > break2); 

dat = [];
dat{1} = [up(range1), Us(range1), dUs(range1).^2];
dat{2} = [up(range2), Us(range2), dUs(range2).^2];
dat{3} = [up(range3), Us(range3), dUs(range3).^2]; 


%% Setup the BayesCalibration objects
obj={};
for ii=1:length(dat)
    obj{ii} = SMASH.BayesCalibration.Calibration;

    % Measurement data - custom structure used by model
    obj{ii}.Measurement.Data = dat{ii}(:,2);
    obj{ii}.Measurement.Grid = dat{ii}(:,1);
    obj{ii}.Measurement.Variance = dat{ii}(:,3);

    % Model handle
    obj{ii}.ModelSettings.Model = @LinearHugoniot;

    % Variable settings
    obj{ii}.VariableSettings.Names = {'c0','s'};
    obj{ii}.VariableSettings.PriorType = {'Uniform','Uniform'};
    obj{ii}.VariableSettings.PriorSettings = {[0.1 10.0], [0.1 10.0]};
    %obj.VariableSettings.PriorType = {'Gauss','Gauss'};
    %obj.VariableSettings.PriorSettings = {[5.35 0.1], [1.35 0.1]};

    % Hyper-parameter priors. Dakota defaults are too constraining, while
    % diffuse priors seem to work well
    %obj{ii}.VariableSettings.HyperSettings = []; % Don't infer
    %obj{ii}.VariableSettings.HyperSettings = [103,102]; % Dakota defaults
    %obj{ii}.VariableSettings.HyperSettings = [1.75,1.75/5];
    obj{ii}.VariableSettings.HyperSettings = [0.01,0.01]; %Non-informative


    % Infered variables - Infer both physical parameters
    obj{ii}.VariableSettings.Infer = logical([1 1]);

    % Shared variables (set equal to experiment #1)
    obj{ii}.VariableSettings.Share = logical([1 1]);
    
    obj{ii}.MCMCSettings.StartPoint = [1,1];
end

% MCMC settings
% Start with MAP point
obj{1}.MCMCSettings.StartPoint = calculateMAP(obj{:},obj{1}.MCMCSettings.StartPoint);


obj{1}.MCMCSettings.ProposalCov = [0.03,0.02].^2;
obj{1}.MCMCSettings.ChainSize = 1e4;
obj{1}.MCMCSettings.BurnIn = 0;
obj{1}.MCMCSettings.DelayedRejectionScale = 0;
obj{1}.MCMCSettings.AdaptiveInterval = 1e3;




%% Run MCMC
profile off
profile on
tic
Results = runMCMC(obj{:});
toc

%% check results
summarize(Results,'allinferred')
view(Results,'allinferred',[],'histogram')
view(Results,'inferred',[],'covariance');



%% Propogate Results - 2 sigma (95% CI)
figure;
h1 = line(up,Us); h1.Color = 'k'; h1.LineStyle = 'none'; h1.Marker = 'o';
h1e = SMASH.Graphics.errorbar2(up,Us,dup,dUs);
h2 = line(up,Us+Results.MCMCResults.ResponseCredibleInterval(:,1)); h2.Color = 'r';
h2 = line(up,Us+Results.MCMCResults.ResponseCredibleInterval(:,2)); h2.Color = 'r'; h2.LineStyle = '--'; 
h2 = line(up,Us+Results.MCMCResults.ResponseCredibleInterval(:,3)); h2.Color = 'r'; h2.LineStyle = '--'; 
h2 = line(up,Us+Results.MCMCResults.ResponsePredictionInterval(:,2)); h2.Color = 'b'; h2.LineStyle = ':'; 
h2 = line(up,Us+Results.MCMCResults.ResponsePredictionInterval(:,3)); h2.Color = 'b'; h2.LineStyle = ':'; 
