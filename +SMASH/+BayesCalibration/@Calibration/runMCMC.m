% Run the calibration 
% 
% Once the calibration object has been properly configured : 
%
%   >> object = runMCMC(object);
%
% will run Markov Chain Monte Carlo (MCMC) to sample from the posterior of
% the inferred variables. The results are saved in the obj.MCMCResults
% structure which will vary depeding on the options specified. 
%
% If multiple calibration objects are specified : 
%    >> object = runMCMC(object1, object2, ...);
%
% The log-likelihoods of each object are summed. The 'Share' variable
% settings can be used to specify which inferred variables are the same
% among the objects. The output object will be blank except for the
% MCMCResults to avoid ambiguity. 
%
% created June 22, 2016 by Justin Brown (Sandia National Laboratories)
%
function ResObj = runMCMC(varargin)

%Load in all calibration objects
obj={}; objcount = 0;
for i = 1:nargin
    if isobject(varargin{i})
        objcount = objcount+1;
        obj{objcount} = varargin{i};
    end
end

if objcount == 1;
    ResObj = obj{1};
else
    ResObj = SMASH.BayesCalibration.Calibration;
    ResObj.VariableSettings = obj{1}.VariableSettings;
    ResObj.MCMCSettings = obj{1}.MCMCSettings;
end
    
Nexp = numel(obj);
infer = [];
share = [];

% Object setup
for i=1:Nexp 
    %Default to all inferred
    if isempty(obj{1}.VariableSettings.Infer)
        obj{i}.VariableSettings.Infer = true(size(obj{1}.VariableSettings.Names));
    end
    
    %Default to no shared variables
    if isempty(obj{1}.VariableSettings.Share)
        obj{i}.VariableSettings.Share = false(size(obj{1}.VariableSettings.Names));
    end
end

%Variable Bookeeping
addinferred{1} = obj{1}.VariableSettings.Infer;
InferredVariables = obj{1}.VariableSettings.Names(addinferred{1});
addcut{1} = ~obj{1}.VariableSettings.Infer;
CutVariables = obj{1}.VariableSettings.Names(addcut{1});
for i = 2:Nexp    
    addinferred{i} = obj{i}.VariableSettings.Infer & ~obj{i}.VariableSettings.Share;
    addcut{i} = ~obj{i}.VariableSettings.Infer & ~obj{i}.VariableSettings.Share;
    addn = obj{i}.VariableSettings.Names(addinferred{i});
    InferredVariables= {InferredVariables{:},addn{:}};
    addn = obj{i}.VariableSettings.Names(addcut{i});
    CutVariables = {CutVariables{:},addn{:}};   
end
NumberInferredVariables = length(InferredVariables);


% Calculate starting likelihood
lik=[];
r=[]; sig=[]; 
%Calculate error covariance first so it's not done every time
for i = 1:Nexp
    [rt sigt]= calculateResiduals(obj{i},obj{i}.MCMCSettings.StartPoint);
    sig{i} = diag(sigt);
end

%Setup initial conditions
I_add = obj{1}.MCMCSettings.StartPoint(obj{1}.VariableSettings.Infer);
FC_add = obj{1}.MCMCSettings.StartPoint(~obj{1}.VariableSettings.Infer);
samps{1} = obj{1}.MCMCSettings.StartPoint; 
for i = 2:Nexp    
    I_add = horzcat(I_add,obj{i}.MCMCSettings.StartPoint(addinferred{i}));
    FC_add = horzcat(FC_add,obj{i}.MCMCSettings.StartPoint(addcut{i}));
    samps{i} = obj{i}.MCMCSettings.StartPoint; 
end

%Stating point likelihood
for i = 1:Nexp 
lik_old(i) = calculateLogLikelihood(obj{i},samps{i},sig{i});
end

chainlength = obj{1}.MCMCSettings.ChainSize;
accepted = zeros([chainlength,length(I_add)]);
I_chain = zeros([chainlength,length(InferredVariables)]);
FC_chain = zeros([chainlength,length(CutVariables)]);
lik_chain=zeros([chainlength,1]);

I_chain(1,:) = I_add;
FC_chain(1,:) = FC_add;
lik_chain(1,:)=sum(lik_old);

%Calibrate hyperparameter if a prior is specified
phi = 1;
inferhyper = false;
if ~isempty(obj{1}.VariableSettings.HyperSettings)
    inferhyper = true;
    hyperchain = zeros([chainlength,1]);
    hyperchain(1,:) = phi;
    NumberInferredVariables = NumberInferredVariables+1;
end


%Some MCMC options
burnin = 0;
if  ~isempty(obj{1}.MCMCSettings.BurnIn) && isnumeric(obj{1}.MCMCSettings.BurnIn)
    burnin = obj{1}.MCMCSettings.BurnIn;
end

drscale = 0;
if ~isempty(obj{1}.MCMCSettings.DelayedRejectionScale) && isnumeric(obj{1}.MCMCSettings.DelayedRejectionScale) 
    drscale = obj{1}.MCMCSettings.DelayedRejectionScale;
end

adaptint = 0;
if  ~isempty(obj{1}.MCMCSettings.AdaptiveInterval) && isnumeric(obj{1}.MCMCSettings.AdaptiveInterval)
    adaptint = obj{1}.MCMCSettings.AdaptiveInterval;
    covchain = [];
    lastAMupdate = burnin;
end




% MCMC loop
wb=SMASH.MUI.Waitbar('Running MCMC');

for MCMCloop=2:chainlength

    
    % Calculate previous step's likelihoods
    lik_old =[];
    for i = 1:Nexp
        %Ensure shared variables are consistent with first experiment
        samps{i}(obj{i}.VariableSettings.Share) = samps{1}(obj{i}.VariableSettings.Share);
        lik_old(i) = calculateLogLikelihood(obj{i},samps{i},sig{i}*phi);
    end
    lik_chain(MCMCloop-1,:)=sum(lik_old);


    % Sample from cut parameter's prior distributions and set shared
    % variables equal to first experiment samples
    FC_add = [];
    for i = 1:Nexp
        if any(addcut{i})
            samps{i}(addcut{i}) = samplePriors(obj{i},addcut{i});
            FC_add = horzcat(FC_add,samps{i}(addcut{i}));
        end
        samps{i}(obj{i}.VariableSettings.Share) = samps{1}(obj{i}.VariableSettings.Share);
    end   
    % Feedback cutting always has prior sample
    if ~isempty(FC_add)
        FC_chain(MCMCloop,:) = FC_add;
    end
   
    
    
    %Loop through each inferred variable and apply metropolisUpdate
    newsamps = samps;
    count = 0; I_add = [];
    for eNum = 1:Nexp
        for sNum=1:length(samps{eNum})
            if addinferred{eNum}(sNum)
                count = count+1;
                [nsamp acc(count)] = inferredUpdate(obj,lik_old,samps,eNum,sNum,sig,phi,drscale);
                newsamps{eNum}(sNum) = nsamp;
                I_add = horzcat(I_add, nsamp);
            end            
        end
    end
    
    % Metropolis update for hyperparameter if inferred
    if inferhyper
        phi = hyperUpdate(obj,lik_old,samps,sig,phi,drscale);
        hyperchain(MCMCloop,:) = phi;
    end
    
    
    %Complete update and ensure shared variables are consistent with first experiment
    samps = newsamps;
    for i = 1:Nexp
        samps{i}(obj{i}.VariableSettings.Share) = samps{1}(obj{i}.VariableSettings.Share);
    end
       
    
I_chain(MCMCloop,:) = I_add; % Update infered variables chain
accepted(MCMCloop,:) = acc;



% If using adaptive metropolis, update the proposal jumps
if adaptint>0 & fix(MCMCloop/adaptint) == MCMCloop/adaptint & MCMCloop > lastAMupdate
   
    
    rcov2 = std(I_chain(lastAMupdate+1:MCMCloop,:));
    %diagonal covariance update
    rcov2 = (rcov2 + 1e-10)*2.38/sqrt(NumberInferredVariables);
    
    count = 0;
    for eNum = 1:Nexp
        for sNum=1:length(samps{eNum})
            if addinferred{eNum}(sNum)
                count = count+1;
                obj{eNum}.VariableSettings.ProposalStd(sNum) = rcov2(count);
            end            
        end
    end
    
    if inferhyper
        h2 = std(hyperchain(lastAMupdate+1:MCMCloop,:));
        h2 = (h2 + 1e-10)*2.38/sqrt(NumberInferredVariables);
        obj{1}.VariableSettings.HyperSettings{3}=h2;
        rcov2(end+1) = h2;
    end
  
    covchain = vertcat(covchain,rcov2);
    lastAMupdate = lastAMupdate+adaptint;
end


if fix(MCMCloop/(chainlength/10)) == MCMCloop/(chainlength/10)
    update(wb,MCMCloop/obj{1}.MCMCSettings.ChainSize);
end
end %% End chain sampling
delete(wb);
    


%Calculate likelihood for last step
lik_old =[];
for i = 1:Nexp
    %Ensure shared variables are consistent with first experiment
    samps{i}(obj{i}.VariableSettings.Share) = samps{1}(obj{i}.VariableSettings.Share);
    lik_old(i) = calculateLogLikelihood(obj{i},samps{i},sig{i}*phi);
end
lik_chain(MCMCloop,:)=sum(lik_old);




% Save results into new object
[arow acol] = size(accepted);
keep = burnin+1:arow;
anum = (1:arow)'; anum = repmat(anum,[1,acol]);
arate = cumsum(accepted)./(anum)*100;
ResObj.MCMCResults.InferredVariables = InferredVariables;
ResObj.MCMCResults.CutVariables = CutVariables;
ResObj.MCMCResults.InferredChain = I_chain(keep,:);
ResObj.MCMCResults.CutChain = FC_chain(keep,:);
ResObj.MCMCResults.AcceptanceRate = arate(keep,:);
ResObj.MCMCResults.LogLikelihood = lik_chain(keep,:);
if inferhyper
    ResObj.MCMCResults.HyperParameterChain = hyperchain(keep,:);
end
if adaptint > 0 
 ResObj.MCMCResults.Cov2 = covchain;   
end

%Generate log likelihood f





end

