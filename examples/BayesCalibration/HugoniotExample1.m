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

range1 = find(up > 0); 
dat= [up(range1), Us(range1), dUs(range1).^2];

%% Setup the BayesCalibration object
obj = SMASH.BayesCalibration.Calibration();

% Measurement data
obj.Measurement.Data = dat(:,2);
obj.Measurement.Grid = dat(:,1);
obj.Measurement.Variance = dat(:,3);

% Model handle
obj.ModelSettings.Model = @LinearHugoniot;

% Variable settings
obj.VariableSettings.Names = {'c0','s'};
obj.VariableSettings.PriorType = {'Uniform','Uniform'};
obj.VariableSettings.PriorSettings = {[0.1 10.0], [0.1 10.0]};
%obj.VariableSettings.PriorType = {'Gauss','Gauss'};
%obj.VariableSettings.PriorSettings = {[5.35 0.1], [1.35 0.1]};

% Error multiplier prior
obj.VariableSettings.HyperSettings = [];
%obj.VariableSettings.HyperSettings = [103,102];
%obj.VariableSettings.HyperSettings = [1.75,1.75/5];
%obj.VariableSettings.HyperSettings = [0,0];

% Solve for MAP point
obj.MCMCSettings.StartPoint = [1,1];
obj.MCMCSettings.StartPoint = calculateMAP(obj,obj.MCMCSettings.StartPoint);

% MCMC settings
obj.MCMCSettings.ProposalCov = 2.4^2/2*[0.03,0.02].^2; % Proposal covariance for metropolis steps
obj.MCMCSettings.ChainSize = 1e4;   % Length of MCMC chain
obj.MCMCSettings.BurnIn = 0;        % Burn-in (typically 0 for MAP solve)
obj.MCMCSettings.DelayedRejectionScale = 2; % Implement delayed rejection with this factor
obj.MCMCSettings.AdaptiveInterval = 1e3;    % Implement adaptive metropolis with this chain step size
obj.MCMCSettings.JointSampling = true;      % Implement joint sampling. If false 1D metropolis is performed

%View settings in GUI
settingsGUI(obj);

%% Run MCMC
tic
Results = runMCMC(obj);
toc

%% view results
summarize(Results,'allinferred')
view(Results,'allinferred',[],'histogram')
view(Results,'inferred',[],'covariance');


%% Propogate Results - 2 sigma (95% CI)
figure;
h1 = line(up,Us); h1.Color = 'k'; h1.LineStyle = 'none'; h1.Marker = 'o';
h1e = SMASH.Graphics.errorbar2(up,Us,dup,dUs);
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponseCredibleInterval(:,1)); h2.Color = 'r';
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponseCredibleInterval(:,2)); h2.Color = 'r'; h2.LineStyle = '--'; 
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponseCredibleInterval(:,3)); h2.Color = 'r'; h2.LineStyle = '--'; 
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponsePredictionInterval(:,2)); h2.Color = 'b'; h2.LineStyle = ':'; 
h2 = line(Results.Measurement.Grid,Results.Measurement.Data+Results.MCMCResults.ResponsePredictionInterval(:,3)); h2.Color = 'b'; h2.LineStyle = ':'; 
