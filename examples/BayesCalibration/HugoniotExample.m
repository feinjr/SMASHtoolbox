%% Parse the hugoniot data
data = dlmread('Al_GunHugData-C.dat');

up = data(:,1);
dup = data(:,2);
Us = data(:,3);
dUs = data(:,4);

[~,I] = sort(up); up = up(I); dup = dup(I); Us = Us(I); dUs = dUs(I);

%% Setup the BayesCalibration object
obj = SMASH.BayesCalibration.Calibration();

% Measurement data
obj.Measurement.Data = Us;
obj.Measurement.Grid = up;

% Model handle
obj.ModelSettings.Model = @LinearHugoniot;

% Variable settings
obj.VariableSettings.Names = {'c0','s'};
%obj.VariableSettings.PriorType = {'Uniform','Uniform'};
%obj.VariableSettings.PriorSettings = {[0.1 10.0], [0.1 10.0]};
obj.VariableSettings.PriorType = {'Gauss','Gauss'};
obj.VariableSettings.PriorSettings = {[5.35 0.1], [1.35 0.1]};

obj.VariableSettings.HyperSettings = [];
%obj.VariableSettings.HyperSettings = {'InvGamma',[104,103]};
%obj.VariableSettings.HyperSettings = {'Gauss',[1,0.1]};
%obj.VariableSettings.HyperSettings = [104,103];
%obj.VariableSettings.HyperSettings = [1.75,1.75/5];


% MCMC settings
obj.MCMCSettings.StartPoint = [1,1];
obj.MCMCSettings.ProposalCov = 2.4^2/2*[0.03,0.02].^2;
obj.MCMCSettings.ChainSize = 1e4;
obj.MCMCSettings.BurnIn = 0;
obj.MCMCSettings.DelayedRejectionScale = 0;
obj.MCMCSettings.AdaptiveInterval = 5e2;
obj.MCMCSettings.JointSampling = true;

% Start with MAP point
obj.MCMCSettings.StartPoint = calculateMAP(obj,obj.MCMCSettings.StartPoint);

%% Run MCMC
profile off
profile on
tic
Results = runMCMC(obj);
toc

%% check results
summarize(Results,'inferred')
view(Results,'inferred','histogram')
view(Results,'inferred','covariance');
std(Results.MCMCResults.InferredChain)
