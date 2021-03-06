% Simple statistical inversion problem (from Queso manual)
%
%   Assume likelihood has known mean and covariance matrix:
%
%   mu  =  -1
%           2
%   
%
%   sig2 =  4 0
%           0 1
%
%   With assumed uniform priors [-inf,inf] sample the posterior with MCMC.



%% Setup the BayesCalibration object
%Initialize
obj = SMASH.BayesCalibration.Calibration();

% Model handle
obj.ModelSettings.Model = @ExampleAFunc;

% Variable settings
obj.VariableSettings.Names = {'theta1','theta2'};
obj.VariableSettings.PriorType = {'Uniform','Uniform'};
obj.VariableSettings.PriorSettings = {[-50.0 50.0], [-50 50.0]};

% MCMC settings
obj.MCMCSettings.StartPoint = [0,0];
obj.MCMCSettings.ChainSize = 1e4;
obj.MCMCSettings.BurnIn = 0;
obj.MCMCSettings.DelayedRejectionScale = 0;
obj.MCMCSettings.AdaptiveInterval = 0;

% Start with MAP point
obj.MCMCSettings.StartPoint = calculateMAP(obj,obj.MCMCSettings.StartPoint);


%Analytic solution
p1 = @(x) 1/(2*sqrt(2*pi)).*exp(-1/8.*(x+1).^2);
p2 = @(x) 1/(sqrt(2*pi)).*exp(-1/2.*(x-2).^2);
x = linspace (-10,10,1e3);

%Open GUI
settingsGUI(obj);

%% Run MCMC
%profile on
tic
R1 = runMCMC(obj);
toc
summarize(R1)
hc=view(R1,'inferred',[],'covariance');
axes(hc{1,1}); h=line(x,p1(x)); h.Color = 'r'; h.LineWidth = 3;
axes(hc{2,2});h=line(x,p2(x)); h.Color = 'r'; h.LineWidth = 3;
title('Baseline');

%% Add adaptive metropolis
obj.MCMCSettings.AdaptiveInterval = 1e2;
tic
R2 = runMCMC(obj);
toc
summarize(R2)
hc=view(R2,'inferred',[],'covariance');
axes(hc{1,1}); h=line(x,p1(x)); h.Color = 'r'; h.LineWidth = 3;
axes(hc{2,2});h=line(x,p2(x)); h.Color = 'r'; h.LineWidth = 3;
title('Add Adaptive Metropolis');

%% Add good proposal covariance
obj.MCMCSettings.ProposalCov = 2.4^2/sqrt(1)*[4,0.5;0.5,1];
tic
R3 = runMCMC(obj);
toc
summarize(R3)
hc=view(R3,'inferred',[],'covariance');
axes(hc{1,1}); h=line(x,p1(x)); h.Color = 'r'; h.LineWidth = 3;
axes(hc{2,2});h=line(x,p2(x)); h.Color = 'r'; h.LineWidth = 3;
title('Add Proposal Covariance');

%% Add delayed rejection
obj.MCMCSettings.DelayedRejectionScale = 3;
tic
R4 = runMCMC(obj);
toc
summarize(R4)
hc=view(R4,'inferred',[],'covariance');
axes(hc{1,1}); h=line(x,p1(x)); h.Color = 'r'; h.LineWidth = 3;
axes(hc{2,2});h=line(x,p2(x)); h.Color = 'r'; h.LineWidth = 3;
title('Add Delayed Rejection');

% %% Run with error term
% obj.MCMCSettings.AdaptiveInterval = 1e2;
% obj.MCMCSettings.ProposalCov = 2.4^2/sqrt(1)*[4,1];
% %obj.VariableSettings.HyperSettings = [0.01,0.01];
% obj.VariableSettings.HyperSettings = [104,103];
% tic
% R5 = runMCMC(obj);
% toc
% summarize(R5,'allinferred')
% hc=view(R1,'inferred',[],'covariance');
% axes(hc{1,1}); h=line(x,p1(x)); h.Color = 'r'; h.LineWidth = 3;
% axes(hc{2,2});h=line(x,p2(x)); h.Color = 'r'; h.LineWidth = 3;
% title('Add Hyper \phi Inference');


% %% Final run
% obj.MCMCSettings.DelayedRejectionScale = 0;
% obj.MCMCSettings.ChainSize = 1e5;
% obj.MCMCSettings.AdaptiveInterval = 1e4;
% tic
% Rfinal = runMCMC(obj);
% toc
% summarize(Rfinal,'inferred')
% [h1,h2]=view(Rfinal,'inferred','histogram');
% axes(h1(1)); h=line(x,p1(x)); h.Color = 'k'; h.LineWidth = 3;
% axes(h1(2));h=line(x,p2(x)); h.Color = 'k'; h.LineWidth = 3;
