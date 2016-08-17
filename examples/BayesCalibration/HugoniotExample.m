% Calibration of a linear Us-up fit to Al Hugoniot data. A single
% multiplier is applied to the experimental error and inferred to produce
% prediction intervals. 

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
obj.Measurement.Variance = dUs.^2;

% Model handle
obj.ModelSettings.Model = @LinearHugoniot;

% Variable settings
obj.VariableSettings.Names = {'c0','s'};
obj.VariableSettings.PriorType = {'Uniform','Uniform'};
obj.VariableSettings.PriorSettings = {[0.1 10.0], [0.1 10.0]};
%obj.VariableSettings.PriorType = {'Gauss','Gauss'};
%obj.VariableSettings.PriorSettings = {[5.35 0.1], [1.35 0.1]};

%obj.VariableSettings.HyperSettings = [];
%obj.VariableSettings.HyperSettings = [103,102];
obj.VariableSettings.HyperSettings = [1.75,1.75/5];
%obj.VariableSettings.HyperSettings = [0,0];

% MCMC settings
obj.MCMCSettings.StartPoint = [5.35,1.35];
%obj.MCMCSettings.ProposalCov = 2.4^2/2*[0.03,0.02].^2;
obj.MCMCSettings.ProposalCov = [0.3e-3, -0.02e-3; -0.02e-3, 0.1e-3];
obj.MCMCSettings.ChainSize = 1e3;
obj.MCMCSettings.BurnIn = 0;
obj.MCMCSettings.DelayedRejectionScale = 2;
obj.MCMCSettings.AdaptiveInterval = 1e3;
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
summarize(Results,'allinferred')
view(Results,'allinferred',[],'histogram')
%view(Results,'inferred',[],'covariance');



%% Propogate Results - 2 sigma (95% CI)
figure;
h1 = line(Results.Measurement.Grid,Results.Measurement.Data); h1.Color = 'k'; h1.LineStyle = 'none'; h1.Marker = 'o';
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponseCredibleInterval(:,1)); h2.Color = 'r';
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponseCredibleInterval(:,2)); h2.Color = 'r'; h2.LineStyle = '--'; 
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponseCredibleInterval(:,3)); h2.Color = 'r'; h2.LineStyle = '--'; 
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponsePredictionInterval(:,2)); h2.Color = 'b'; h2.LineStyle = ':'; 
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponsePredictionInterval(:,3)); h2.Color = 'b'; h2.LineStyle = ':'; 
