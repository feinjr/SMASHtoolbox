% Calibration of a linear Us-up fit to Al Hugoniot data. Each datum is
% treated as an individual experiment such that the hyperparameters (error
% multipliers) are inferred individually to give more accurate prediction
% intervals. 


%% Parse the hugoniot data
data = dlmread('Al_GunHugData-C.dat');

up = data(:,1);
dup = data(:,2);
Us = data(:,3);
dUs = data(:,4);

[~,I] = sort(up); up = up(I); dup = dup(I); Us = Us(I); dUs = dUs(I);


%% Setup the BayesCalibration objects
obj={};
for ii=1:length(up)
    obj{ii} = SMASH.BayesCalibration.Calibration;

    % Measurement data - custom structure used by model
    obj{ii}.Measurement.Data = Us(ii);
    obj{ii}.Measurement.Grid = up(ii);
    obj{ii}.Measurement.Variance = dUs(ii).^2;

    % Model handle
    obj{ii}.ModelSettings.Model = @LinearHugoniot;

    % Variable settings
    obj{ii}.VariableSettings.Names = {'c0','s'};
    obj{ii}.VariableSettings.PriorType = {'Uniform','Uniform'};
    obj{ii}.VariableSettings.PriorSettings = {[0.1 10.0], [0.1 10.0]};
    %obj.VariableSettings.PriorType = {'Gauss','Gauss'};
    %obj.VariableSettings.PriorSettings = {[5.35 0.1], [1.35 0.1]};

    % Hyper-parameter priors. Purely non-informative is too difuse, while
    % Dakota defaults are too contraining. 
    %obj{ii}.VariableSettings.HyperSettings = []; % Don't infer
    %obj{ii}.VariableSettings.HyperSettings = [103,102]; % Dakota defaults
    obj{ii}.VariableSettings.HyperSettings = [1.75,1.75/5];
    %obj{ii}.VariableSettings.HyperSettings = [0,0]; %Non-informative


    % Infered variables - Infer both physical parameters
    obj{ii}.VariableSettings.Infer = logical([1 1]);

    % Shared variables (set equal to experiment #1)
    obj{ii}.VariableSettings.Share = logical([1 1]);
    
    obj{ii}.MCMCSettings.StartPoint = [1,1];
end

% MCMC settings
% Start with MAP point
obj{1}.MCMCSettings.StartPoint = calculateMAP(obj{:},obj{1}.MCMCSettings.StartPoint);


%obj{1}.MCMCSettings.ProposalCov = 2.4^2/2*[0.03,0.02].^2;
obj{1}.MCMCSettings.ProposalCov = [0.3e-3, -0.02e-3; -0.02e-3, 0.1e-3];
obj{1}.MCMCSettings.ChainSize = 1e4;
obj{1}.MCMCSettings.BurnIn = 0;
obj{1}.MCMCSettings.DelayedRejectionScale = 2;
obj{1}.MCMCSettings.AdaptiveInterval = 1e3;
obj{1}.MCMCSettings.JointSampling = true;




%% Run MCMC
profile off
profile on
tic
Results = runMCMC(obj{:});
toc

%% check results
summarize(Results,'allinferred')
view(Results,'inferred',[],'histogram')
%view(Results,'inferred',[],'covariance');



%% Propogate Results - 2 sigma (95% CI)
figure;
h1 = line(up,Us); h1.Color = 'k'; h1.LineStyle = 'none'; h1.Marker = 'o';
h2 = line(up,Us+Results.MCMCResults.ResponseCredibleInterval(:,1)); h2.Color = 'r';
h2 = line(up,Us+Results.MCMCResults.ResponseCredibleInterval(:,2)); h2.Color = 'r'; h2.LineStyle = '--'; 
h2 = line(up,Us+Results.MCMCResults.ResponseCredibleInterval(:,3)); h2.Color = 'r'; h2.LineStyle = '--'; 
h2 = line(up,Us+Results.MCMCResults.ResponsePredictionInterval(:,2)); h2.Color = 'b'; h2.LineStyle = ':'; 
h2 = line(up,Us+Results.MCMCResults.ResponsePredictionInterval(:,3)); h2.Color = 'b'; h2.LineStyle = ':'; 
