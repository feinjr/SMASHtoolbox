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

%% Load in all calibration objects
obj={}; objcount = 0;
for i = 1:nargin
    if isobject(varargin{i})
        objcount = objcount+1;
        obj{objcount} = varargin{i};
    end
end
Nexp = numel(obj);

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

% Results configuration
if objcount == 1;
    ResObj = obj{1};
else
    ResObj = SMASH.BayesCalibration.Calibration;
    ResObj.VariableSettings = obj{1}.VariableSettings;
    ResObj.MCMCSettings = obj{1}.MCMCSettings;
end



%Variable Bookeeping
addinferred{1} = obj{1}.VariableSettings.Infer;
InferredVariables = obj{1}.VariableSettings.Names(addinferred{1});
addcut{1} = ~obj{1}.VariableSettings.Infer;
CutVariables = obj{1}.VariableSettings.Names(addcut{1});
for ii = 2:Nexp    
    addinferred{ii} = obj{ii}.VariableSettings.Infer & ~obj{ii}.VariableSettings.Share;
    addcut{ii} = ~obj{ii}.VariableSettings.Infer & ~obj{ii}.VariableSettings.Share;
    addn = obj{ii}.VariableSettings.Names(addinferred{ii});
    InferredVariables= {InferredVariables{:},addn{:}};
    addn = obj{ii}.VariableSettings.Names(addcut{ii});
    CutVariables = {CutVariables{:},addn{:}};   
end
NumberInferredVariables = length(InferredVariables);

%Calculate error covariance first so it's not done every time
r0={size(obj)}; 
sig2={size(obj)}; 
for ii = 1:Nexp
    [rt, sig2t]= calculateResiduals(obj{ii},obj{ii}.MCMCSettings.StartPoint);
    r0{ii} = sig2t;
    sig2{ii} = sig2t;
    if isvector(sig2{ii})
         sig2inv{ii} = inv(diag(sig2t));
    else
        sig2inv{ii} = inv(sig2t);
    end
end

%Setup initial conditions
I_update = obj{1}.MCMCSettings.StartPoint(obj{1}.VariableSettings.Infer);
FC_add = obj{1}.MCMCSettings.StartPoint(~obj{1}.VariableSettings.Infer);
samps{1} = obj{1}.MCMCSettings.StartPoint; 
for ii = 2:Nexp    
    I_update = horzcat(I_update,obj{ii}.MCMCSettings.StartPoint(addinferred{ii}));
    FC_add = horzcat(FC_add,obj{ii}.MCMCSettings.StartPoint(addcut{ii}));
    samps{ii} = obj{ii}.MCMCSettings.StartPoint; 
end

%Stating point likelihood
lik_old =zeros([1,Nexp]);
for ii = 1:Nexp 
lik_old(ii) = calculateLogLikelihood(obj{ii},samps{ii},sig2{ii});
end


% Starting prior likelihood
lprior_old = zeros([1,NumberInferredVariables]);
count = 0;
for eNum = 1:length(obj)
    for sNum=1:length(samps{eNum})
        if addinferred{eNum}(sNum)
        count = count+1;
        priorfunc{count}= str2func(obj{eNum}.VariableSettings.PriorType{sNum});
        priorvals{count} = num2cell(obj{eNum}.VariableSettings.PriorSettings{sNum});
        lprior_old(count) = priorfunc{count}(priorvals{count}{:},samps{eNum}(sNum));
        end            
    end
end 



chainlength = obj{1}.MCMCSettings.ChainSize;
accepted = zeros([chainlength,length(I_update)]);
I_chain = zeros([chainlength,length(InferredVariables)]);
FC_chain = zeros([chainlength,length(CutVariables)]);
lik_chain=zeros([chainlength,1]);

I_chain(1,:) = I_update;
FC_chain(1,:) = FC_add;
lik_chain(1,:)=sum(lik_old);

%Hyper-parameter settings
phi = 1;
inferhyper = false;
if ~isempty(obj{1}.VariableSettings.HyperSettings)
    inferhyper = true;
    hyperchain = zeros([chainlength,1]);
    hyperchain(1,:) = phi;

    phi_priorvals = obj{1}.VariableSettings.HyperSettings;
    
    a0 = phi_priorvals(1);
    b0 = phi_priorvals(2);
    a1 = a0 + 0.5*numel(r0);
end


%Some MCMC options
qcov = [];
qmean = obj{1}.MCMCSettings.StartPoint;
% Initial proposal covariance if specified
if ~isempty(obj{1}.MCMCSettings.ProposalCov)
    qcov = obj{1}.MCMCSettings.ProposalCov;
    if isvector(qcov)
        qcov = diag(qcov);
    end
    R = chol(qcov);
end
% Set burnin  
burnin = 0;
if  ~isempty(obj{1}.MCMCSettings.BurnIn) && isnumeric(obj{1}.MCMCSettings.BurnIn)
    burnin = obj{1}.MCMCSettings.BurnIn;
end
% Set delayed rejection scaling
drscale = 0;
if ~isempty(obj{1}.MCMCSettings.DelayedRejectionScale) && isnumeric(obj{1}.MCMCSettings.DelayedRejectionScale) 
    drscale = obj{1}.MCMCSettings.DelayedRejectionScale;
    if ~isempty(qcov)
        R2 = R/drscale;
        iR = inv(R);
    end
end
% Set adaptive metropolis
adaptint = 0;
if  ~isempty(obj{1}.MCMCSettings.AdaptiveInterval) && isnumeric(obj{1}.MCMCSettings.AdaptiveInterval)
    adaptint = obj{1}.MCMCSettings.AdaptiveInterval;
    lastAMupdate = burnin;
    qcoveps = eps.*eye(NumberInferredVariables);
        if obj{1}.MCMCSettings.JointSampling
            sd = 2.38^2/NumberInferredVariables; %AM ideal covariance scaling
        else
            sd = 2.38^2; %Single variable sampling : 50% acceptance rate
        end
    
end


%% %%%%%%%%%%%%%%%%%%%%  MCMC loop  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wb=SMASH.MUI.Waitbar('Running MCMC');
for MCMCloop=2:chainlength
    
   
  
    % Sample from cut parameter's prior distributions and set shared
    % variables equal to first experiment samples
    FC_add = [];
    for ii = 1:Nexp
        if any(addcut{ii})
            samps{ii}(addcut{ii}) = samplePriors(obj{ii},addcut{ii});
            FC_add = horzcat(FC_add,samps{ii}(addcut{ii}));
        end
        samps{ii}(obj{ii}.VariableSettings.Share) = samps{1}(obj{ii}.VariableSettings.Share);
    end   
    
    % Feedback cutting always has prior sample
    if ~isempty(FC_add)
        FC_chain(MCMCloop,:) = FC_add;
    end
    
    
    
    if obj{1}.MCMCSettings.JointSampling
        % Apply single metropolis update for all variables
        JointUpdate;
    else
        IndividualUpdate;
    end
      
    
    
    %Update hyperparameter
    if inferhyper
        hyperchain(MCMCloop,:) = phi;
        
        rsum=0; 
        for ii = 1:Nexp
            rsum = rsum - lik_old(ii) - numel(r0)/2*log(2*pi)-sum(log(diag(chol(sig2{ii}))));
        end
        
        b1 = b0 + rsum;
        phi = InvGamma(a1,b1);
     
    end
   
       
    
% Update chains      
I_chain(MCMCloop,:) = I_update; 
accepted(MCMCloop,:) = acc;
lik_chain(MCMCloop,:)=sum(lik_old);


% If using adaptive metropolis, update the proposal jumps
if adaptint>0 && fix(MCMCloop/adaptint) == MCMCloop/adaptint && MCMCloop > lastAMupdate && MCMCloop > burnin
   
    % Direct calculation : faster than recursion for chains < 1e6? 
    % See Haario et al. Stat Comput 2006 for DRAM algorithm
    qcov = sd.*(cov(I_chain(burnin+1:MCMCloop,:))+qcoveps);
    
    R = chol(qcov);
    R2 = R./drscale;
    iR = inv(R);

    lastAMupdate = lastAMupdate+adaptint;
end

if fix(MCMCloop/(chainlength/10)) == MCMCloop/(chainlength/10)
    update(wb,MCMCloop/obj{1}.MCMCSettings.ChainSize);
end


end %End MCMC loop
delete(wb);
   

% Save results 
[arow,acol] = size(accepted);
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
    ResObj.MCMCSettings.ProposalCov = qcov;
end
 


%% %%%%%%%%%%%%%    Joint DRAM update (embedded for speed)     %%%%%%%%%%%
function JointUpdate
    
%Use Gaussian step if proposal is specified
lprior_new = lprior_old*0;

if ~isempty(qcov)
    trialparams = I_update + randn(size(I_update))*R;
    count = 0; trialsamps = samps;
    for eNum = 1:length(obj)
        for sNum=1:length(samps{eNum})
            if addinferred{eNum}(sNum)
            count = count+1;
            trialsamps{eNum}(sNum) = trialparams(count);
            lprior_new(count) = priorfunc{count}(priorvals{count}{:},trialsamps{eNum}(sNum));
            end            
        end
    end 
    
    
%Otherwise sample from prior
else
    count = 0; trialsamps = samps;
    for eNum = 1:length(obj)
        for sNum=1:length(samps{eNum})
            if addinferred{eNum}(sNum)
            count = count+1;
            trialparams(count) = priorfunc{count}(priorvals{count}{:});
            trialsamps{eNum}(sNum) = trialparams(count);
            lprior_new(count) = priorfunc{count}(priorvals{count}{:},trialsamps{eNum}(sNum));
            end            
        end
    end       
end

% trialphi = phi;
% lphi_old = 0; lphi_new = 0;
% if inferhyper
%     phistep = 0.01;
%     trialphi = phi + randn*phistep;
%     if trialphi < 0
%         trialphi = phi;
%     end
%     lphi_old = phi_priorfunc(phi_priorvals{:},phi);
%     lphi_new = phi_priorfunc(phi_priorvals{:},trialphi);
% end



%Find likelihood of trial state
lik_new = zeros([1,Nexp]);
for ii = 1:Nexp
    %Update shared variables
    trialsamps{ii}(obj{ii}.VariableSettings.Share) = trialsamps{1}(obj{ii}.VariableSettings.Share);
    lik_new(ii) = calculateLogLikelihood(obj{ii},trialsamps{ii},sig2{ii}*(phi.^2));
end

alpha = min(1,exp(sum(lik_new)-sum(lik_old) + sum(lprior_new) - sum(lprior_old)));
%alpha = min(0,sum(lik_new)-sum(lik_old) + sum(lprior_new) - sum(lprior_old));

% Metropolis update
if rand <= alpha
%if log(rand) <= alpha
   acc = 1;  % Accept the candidate
   %prob = min(alpha,1);     % Accept with probability min(alpha,1)
   I_update = trialparams;
   samps = trialsamps;
   lik_old = lik_new; 
   lprior_old = lprior_new;
   %phi = trialphi;
else
   acc = 0; 
end
   
%Delayed rejection (single stage)
if acc == 0 && drscale > 0 && ~isempty(qcov)

    %trialparams2 = trialparams + randn(size(I_update))*R2;
    trialparams2 = I_update + randn(size(I_update))*R2;
    count = 0; trialsamps2 = samps;
    for eNum = 1:length(obj)
        for sNum=1:length(samps{eNum})
            if addinferred{eNum}(sNum)
            count = count+1;
            trialsamps2{eNum}(sNum) = trialparams2(count);
            lprior_new2(count) = priorfunc{count}(priorvals{count}{:},trialsamps2{eNum}(sNum));
            end            
        end
    end 
    
    % Proposal likelihood
    lik_new2 =zeros([1,Nexp]);
    for ii = 1:length(obj)
        %Update shared variables
        trialsamps2{ii}(obj{ii}.VariableSettings.Share) = trialsamps2{1}(obj{ii}.VariableSettings.Share);
        lik_new2(ii) = calculateLogLikelihood(obj{ii},trialsamps2{ii},sig2{ii}*(phi.^2));
    end
    
    q1 = exp(-0.5*(norm((trialparams2-trialparams)*iR)^2-norm((I_update-trialparams)*iR)^2));
    
    % DR algorithm
    alpha32 = min(1,exp(sum(lik_new)-sum(lik_new2) + sum(lprior_new) - sum(lprior_new2)));
    L2 = exp(sum(lik_new2) + sum(lprior_new2) -sum(lik_old)-sum(lprior_old) );
    alpha13 = min(1, (L2*q1*(1-alpha32))/(1-alpha));
    
    if rand <= alpha13
       acc = 1;  % Accept the candidate
       %prob = min(alpha,1);     % Accept with probability min(alpha,1)
       I_update = trialparams2;
       samps = trialsamps2;
       lik_old = lik_new2; 
       lprior_old = lprior_new2;
    else
       acc = 0; 
    end
    
    
end



end % End Joint Update


%% %%%%%%%%%%%%%%%%%%%%%%%%%%  Individual update   %%%%%%%%%%%%%%%%%%%%%%%%
function IndividualUpdate
    
%Loop through each inferred variable and apply metropolisUpdate

count = 0; 
acc = 0*I_chain(MCMCloop-1,:);
savedsamps = samps;
savedparams = I_update;
savedpriors = lprior_old;

propsteps = diag(R);
for eNum = 1:Nexp
    for sNum=1:length(samps{eNum})
        if addinferred{eNum}(sNum)
            count = count+1;
            
            %Reset to old at each step
            trialsamps = samps;
            trialparams = I_update;
            lprior_new = lprior_old;
            
            % Gaussian proposal
            if ~isempty(qcov)
                trialparams(count) = trialparams(count) + randn*propsteps(count);
                trialsamps{eNum}(sNum) = trialparams(count);
            % Prior proposal
            else
                trialparams(count) = priorfunc{count}(priorvals{count}{:});
                trialsamps{eNum}(sNum) = trialparams(count);
                lprior_new(count) = priorfunc{count}(priorvals{count}{:},trialsamps{eNum}(sNum));
            end
            

            %Find likelihood of trial state
            lik_new = zeros([1,Nexp]);
            for ii = 1:Nexp
                %Update shared variables
                trialsamps{ii}(obj{ii}.VariableSettings.Share) = trialsamps{1}(obj{ii}.VariableSettings.Share);
                lik_new(ii) = calculateLogLikelihood(obj{ii},trialsamps{ii},sig2{ii}*(phi.^2));
            end
            alpha = min(1,exp(sum(lik_new)-sum(lik_old) + sum(lprior_new) - sum(lprior_old)));


            % Metropolis update
            if rand <= alpha
               acc(count) = 1;  % Accept the candidate
               %prob = min(alpha,1);     % Accept with probability min(alpha,1)
               savedsamps{eNum}(sNum) = trialsamps{eNum}(sNum);
               savedparams(count) = trialparams(count);
               savedpriors(count) = lprior_new(count);
            else
               acc(count) = 0; 
            end
        

        end            
    end
end

samps = savedsamps;
I_update = savedparams;
lprior_old = savedpriors;

% Reset old likelihood
lik_old =zeros([1,Nexp]);
for ii = 1:Nexp
    %Ensure shared variables are consistent with first experiment
    samps{ii}(obj{ii}.VariableSettings.Share) = samps{1}(obj{ii}.VariableSettings.Share);
    lik_old(ii) = calculateLogLikelihood(obj{ii},samps{ii},sig2{ii}*(phi.^2));
end
        
    
end %End individual update




















end %%End runMCMC













