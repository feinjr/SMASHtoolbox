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
for ii = 1:nargin
    if isobject(varargin{ii})
        objcount = objcount+1;
        obj{objcount} = varargin{ii};
    end
end
Nexp = numel(obj);

% Object setup
for ii=1:Nexp 
    %Default to all inferred
    if isempty(obj{1}.VariableSettings.Infer)
        obj{ii}.VariableSettings.Infer = true(size(obj{1}.VariableSettings.Names));
    end
    
    %Default to no shared variables
    if isempty(obj{1}.VariableSettings.Share)
        obj{ii}.VariableSettings.Share = false(size(obj{1}.VariableSettings.Names));
    end 
end

% Results configuration - only output 1 object
% Copy properties if only 1 object, otherwise just keep the first settings
if objcount == 1;
    ResObj = obj{1};
else
    ResObj = SMASH.BayesCalibration.Calibration;
    ResObj.VariableSettings = obj{1}.VariableSettings;
    ResObj.MCMCSettings = obj{1}.MCMCSettings;
end



%Variable Bookeeping
%Seperate first objects inferred and feedback cut variables
addinferred{1} = obj{1}.VariableSettings.Infer;
InferredVariables = obj{1}.VariableSettings.Names(addinferred{1});
addcut{1} = ~obj{1}.VariableSettings.Infer;
CutVariables = obj{1}.VariableSettings.Names(addcut{1});
for ii = 2:Nexp    
    %Loop through each other object and save new inferred and cut variables
    %if they are not shared with the first object.
    addinferred{ii} = obj{ii}.VariableSettings.Infer & ~obj{ii}.VariableSettings.Share;
    addcut{ii} = ~obj{ii}.VariableSettings.Infer & ~obj{ii}.VariableSettings.Share;
    addn = obj{ii}.VariableSettings.Names(addinferred{ii});
    InferredVariables= {InferredVariables{:},addn{:}};
    addn = obj{ii}.VariableSettings.Names(addcut{ii});
    CutVariables = {CutVariables{:},addn{:}};   
end
NumberInferredVariables = length(InferredVariables);

%Calculate error covariance first so it's not done every time
r0={size(obj)}; %Initial residuals saved as a cell for each object
sig2={size(obj)}; %Initial covariance saved as a cell for each object
ESS = []; %Effective sample size for each experiment
for ii = 1:Nexp
    %User model must return residuals and covariance
    [rt, sig2t]= calculateResiduals(obj{ii},obj{ii}.MCMCSettings.StartPoint);
    r0{ii} = sig2t;
    sig2{ii} = sig2t;
    %Speedups in code if covariance is a diagonal matrix, this is tracked
    %but the inverse is carried as a matrix.
    if isvector(sig2{ii})
         sig2inv{ii} = inv(diag(sig2t));
    else
        sig2inv{ii} = inv(sig2t);
    end
    
    if ~isempty(obj{ii}.VariableSettings.EffectiveSampleSize);
        ESS(ii) = obj{ii}.VariableSettings.EffectiveSampleSize;
    else
        ESS(ii) = length(rt); 
    end
     
end

%Setup initial conditions
%Inferred variables chain start, object 1
I_update = obj{1}.MCMCSettings.StartPoint(obj{1}.VariableSettings.Infer);
%Cut variables chain start, object 1
FC_add = obj{1}.MCMCSettings.StartPoint(~obj{1}.VariableSettings.Infer);
%Samps is current value of inferred variables
samps{1} = obj{1}.MCMCSettings.StartPoint; 
%Add on terms for the rest of objects
for ii = 2:Nexp
    I_update = horzcat(I_update,obj{ii}.MCMCSettings.StartPoint(addinferred{ii}));
    FC_add = horzcat(FC_add,obj{ii}.MCMCSettings.StartPoint(addcut{ii}));
    samps{ii} = obj{ii}.MCMCSettings.StartPoint; 
end

%Stating point likelihood
lik_old =zeros([1,Nexp]);
response_old = {lik_old};
error_old = {lik_old};
%For each experiment calculate the log-likelihood and residuals
for ii = 1:Nexp 
    samps{ii}(obj{ii}.VariableSettings.Share) = samps{1}(obj{ii}.VariableSettings.Share);
    [lik_old(ii),response_old{ii},error_old{ii}] = calculateLogLikelihood(obj{ii},samps{ii},sig2{ii},sig2inv{ii},ESS(ii));
end

% Starting prior likelihood
lprior_old = zeros([1,NumberInferredVariables]);
count = 0;
%Loop through each experiment and then each inferred variable and calculate
%the prior function and values. These are saved for future use before
%evaluating the starting point.
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

%Pre-allocate the chain sizes
chainlength = obj{1}.MCMCSettings.ChainSize;
%Accepted values for calculating acceptance rate
if obj{1}.MCMCSettings.JointSampling
    accepted = zeros([chainlength,1]);
else
    accepted = zeros([chainlength,length(I_update)]);
end
%Inferred variables
I_chain = zeros([chainlength,length(InferredVariables)]);
%Cut variables
FC_chain = zeros([chainlength,length(CutVariables)]);
%Log-likelihood values
lik_chain=zeros([chainlength,1]);
%Residual values are concatenated and saved in a single row
response_chain=zeros([chainlength,numel(cell2mat(response_old'))]);
%Residual errors correspond to responses
error_chain=response_chain;

%Update chain with initial values
I_chain(1,:) = I_update;
FC_chain(1,:) = FC_add;
lik_chain(1,:)=sum(lik_old);
response_chain(1,:) =cell2mat(response_old')';
error_chain(1,:) =cell2mat(error_old')';

%Hyper-parameter settings
inferhyper = false;
phi=ones([1,Nexp]);
hyperchain = ones([chainlength,length(phi)]);
hyperacc = ones([chainlength,1]);
a0 = []; b0 = [];
%Hyper settings are dictated by object 1. If they exist then all other
%experiments are given the same values unless they are specified. 
if ~isempty(obj{1}.VariableSettings.HyperSettings)
    inferhyper = true;
    for ii=1:Nexp
        if ~isempty(obj{ii}.VariableSettings.HyperSettings)
            phi(ii) = 1;
            phi_priorvals = obj{ii}.VariableSettings.HyperSettings;
            a0(ii) = phi_priorvals(1);
            b0(ii) = phi_priorvals(2);
        else
            phi(ii) = phi(1);
            a0(ii) = a0(1);
            b0(ii) = b0(1);
        end        
    end
    
    %Define proposal covariance for phi
    qcov_phi = diag(0.1*ones(size(phi))).^2;
    R_phi = chol(qcov_phi); iR_phi = inv(R_phi);
        
end


%Some MCMC options
qcov = [];
% Initial proposal covariance if specified. If it is left empty, then
% proposal samples will be drawn from the prior distribution until
% it is calculated during an adaptation step.
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

% Set delayed rejection scaling : from Haario et al. (2006)
drscale = 0;
if ~isempty(obj{1}.MCMCSettings.DelayedRejectionScale) && isnumeric(obj{1}.MCMCSettings.DelayedRejectionScale) 
    drscale = obj{1}.MCMCSettings.DelayedRejectionScale;
    if ~isempty(qcov)
        iR = inv(R);
    end
end

% Set adaptive metropolis : from Haario et al. (2006)
adaptint = 0;
if  ~isempty(obj{1}.MCMCSettings.AdaptiveInterval) && isnumeric(obj{1}.MCMCSettings.AdaptiveInterval)
    adaptint = obj{1}.MCMCSettings.AdaptiveInterval;
    lastAMupdate = burnin;
    qcoveps = eps.*eye(NumberInferredVariables);
        if obj{1}.MCMCSettings.JointSampling
            %AM ideal covariance scaling
            sd = 2.38^2/NumberInferredVariables; 
        else
            %Single variable sampling : 40% acceptance rate?
            %sd = 2.38^2/NumberInferredVariables; 
            sd = 2.38^2/1;
        end
    
end

% Some error checking
assert(length(diag(R)) == length(InferredVariables),'ERROR : Proposal covariance is not compatible with number of inferred variables');



%% %%%%%%%%%%%%%%%%%%%%  MCMC loop  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wb=SMASH.MUI.Waitbar('Running MCMC');
for MCMCloop=2:chainlength
    
    %Update error multiplier - for normal phi likelihood with known mean,
    %the conjugate prior is an inverse gamma. This allows direct sampling
    %of the posterior 
    if inferhyper
        HyperUpdate;
        hyperchain(MCMCloop,:) = phi;
    end
    
             
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
    
    % Feedback cutting always just samples from prior distriubtion
    if ~isempty(FC_add)
        FC_chain(MCMCloop,:) = FC_add;
    end
    
    % Reset the likelihood given parameter updates
    lik_old =zeros([1,Nexp]);
    response_old = {lik_old};
    for ii = 1:Nexp
        [lik_old(ii),response_old{ii}] = calculateLogLikelihood(obj{ii},samps{ii},sig2{ii}*phi(ii),sig2inv{ii}/phi(ii),ESS(ii));
    end
    
   
    if obj{1}.MCMCSettings.JointSampling
        % Apply single metropolis update for all variables with
        % multivariate normal proposal (DRAM, Haario et al. (2006))
        JointUpdate;
    else
        % Apply a metropolis update seperately for each variable using an
        % independent normal proposal
        IndividualUpdate;
    end
     
    
    % Update chains      
    I_chain(MCMCloop,:) = I_update; 
    accepted(MCMCloop,:) = acc;
    lik_chain(MCMCloop,:)=sum(lik_old);
    response_chain(MCMCloop,:)=cell2mat(response_old')';
    error_chain(MCMCloop,:)=cell2mat(error_old')';

    % If using adaptive metropolis, update the proposal jumps
    if adaptint>0 && fix(MCMCloop/adaptint) == MCMCloop/adaptint && MCMCloop > lastAMupdate && MCMCloop > burnin

        % Direct calculation : faster than recursion for chains < 1e6? 
        % See Haario et al. Stat Comput 2006 for DRAM algorithm
        % Covariance of the chain from burnin up to current point
        qcov = sd.*(cov(I_chain(burnin+1:MCMCloop,:))+qcoveps);
        R = chol(qcov); iR = inv(R);

        
        %Update phi covariance
        if inferhyper
            qcov_phi = 2.38^2/length(phi).*(cov(hyperchain(burnin+1:MCMCloop,:))+eps.*eye(length(phi)));
            R_phi = chol(qcov_phi);iR_phi = inv(R_phi);
        end
        
       
        % Update step
        lastAMupdate = lastAMupdate+adaptint;

        %obj{1}.MCMCSettings.JointSampling = true;
    end

    
    %Update waitbar
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
ResObj.MCMCResults.HyperChain = hyperchain(keep,:);

%Credible intervals
cloudobj = SMASH.MonteCarlo.Cloud(response_chain(keep,:),'table');
moments = summarize(cloudobj);
ResObj.MCMCResults.ResponseMoments = moments;
sec = sqrt(moments(:,2));
ResObj.MCMCResults.ResponseCredibleInterval = [moments(:,1),moments(:,1)+2*sec,moments(:,1)-2*sec];

%Prediction intervals
pchain_up = response_chain(keep,:)+2*error_chain(keep,:);
pchain_down = response_chain(keep,:)-2*error_chain(keep,:);
ResObj.MCMCResults.ResponsePredictionInterval = [moments(:,1),mean(pchain_up)',mean(pchain_down)'];
%sep = mean(error_chain)'; 
%ResObj.MCMCResults.ResponsePredictionInterval = [moments(:,1),moments(:,1)+2*sec+2*sep,moments(:,1)-2*sec-2*sep];


%Final proposal covariance
if adaptint > 0 
    ResObj.MCMCSettings.ProposalCov = qcov;
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following functions perform the Metropolis-Hastings update and are
% embedded to avoid variable passing between functions to increase speed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%    Joint DRAM update %%%%%%%%%%%
function JointUpdate
    
%Initial updated inferred variables log-likelihoods
lprior_new = lprior_old*0;
%Draw new samples from multivariate normal distrubtion with step sizes
%given by proposal covariance. Loop through each sample and update sample
%values and log-likelihood of the priors
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
    

%Otherwise loop through each inferred variable and draw an new sample from prior
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


%Find likelihood of trial state
lik_new = zeros([1,Nexp]);
response_new = {lik_new};
error_new = {lik_new};
for ii = 1:Nexp
    %Update shared variables
    trialsamps{ii}(obj{ii}.VariableSettings.Share) = trialsamps{1}(obj{ii}.VariableSettings.Share);
    [lik_new(ii),response_new{ii},error_new{ii}]  = calculateLogLikelihood(obj{ii},trialsamps{ii},sig2{ii}*phi(ii),sig2inv{ii}/phi(ii),ESS(ii));
end

%Calculate alpha (update criteria)
alpha = min(1,exp(sum(lik_new)-sum(lik_old) + sum(lprior_new) - sum(lprior_old)),'includenan');
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
   response_old = response_new;
   error_old = error_new;
else
   acc = 0; 
end
   
%Delayed rejection (single stage)
if acc == 0 && drscale > 0 && ~isempty(qcov)

    %Is second stage move from previous trial or old value? Old value seems
    %to produce correct results...
    %trialparams2 = trialparams + randn(size(I_update))*R/drscale;
    trialparams2 = I_update + randn(size(I_update))*R/drscale;
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
    response_new2 = {lik_new2};
    error_new2 = {lik_new2};
    for ii = 1:length(obj)
        %Update shared variables
        trialsamps2{ii}(obj{ii}.VariableSettings.Share) = trialsamps2{1}(obj{ii}.VariableSettings.Share);
        [lik_new2(ii),response_new2{ii},error_new2{ii}] = calculateLogLikelihood(obj{ii},trialsamps2{ii},sig2{ii}*phi(ii),sig2inv{ii}./phi(ii),ESS(ii));
    end
    
    % DR algorithm - only single stage
    q1 = exp(-0.5*(norm((trialparams2-trialparams)*iR)^2-norm((I_update-trialparams)*iR)^2));
    alpha32 = min(1,exp(sum(lik_new)-sum(lik_new2) + sum(lprior_new) - sum(lprior_new2)),'includenan');
    L2 = exp(sum(lik_new2) + sum(lprior_new2) -sum(lik_old)-sum(lprior_old) );
    alpha13 = min(1, (L2*q1*(1-alpha32))/(1-alpha),'includenan');
    
    if rand <= alpha13
       acc = 1;  % Accept the candidate
       %prob = min(alpha,1);     % Accept with probability min(alpha,1)
       I_update = trialparams2;
       samps = trialsamps2;
       lik_old = lik_new2; 
       lprior_old = lprior_new2;
       response_old = response_new2;
       error_old = error_new2;
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

if ~isempty(qcov)
    propsteps = diag(R);
end

%Start loop by searching each experiment
for eNum = 1:Nexp
    %Next step into each inferred variable
    for sNum=1:length(samps{eNum})
        %If an inferred variable is found, update the count
        if addinferred{eNum}(sNum)
            count = count+1;
            
            %Reset to old at each step
            trialsamps = samps;
            trialparams = I_update;
            lprior_new = lprior_old;
            
            %Gaussian proposals step based on diagonal of covariance
            if ~isempty(qcov)
                trialparams(count) = I_update(count) + randn*propsteps(count);
                trialsamps{eNum}(sNum) = trialparams(count);
            %If proposal covariance does not exist just draw a sample from
            %the prior
            else
                trialparams(count) = priorfunc{count}(priorvals{count}{:});
                trialsamps{eNum}(sNum) = trialparams(count);
            end
            
            %Prior likelihood
            lprior_new(count) = priorfunc{count}(priorvals{count}{:},trialsamps{eNum}(sNum));

            %Find likelihood of trial state
            lik_new = zeros([1,Nexp]);
            response_new = {lik_new};
            for ii = 1:Nexp
                %Update shared variables
                trialsamps{ii}(obj{ii}.VariableSettings.Share) = trialsamps{1}(obj{ii}.VariableSettings.Share);
                lik_new(ii) = calculateLogLikelihood(obj{ii},trialsamps{ii},sig2{ii}*phi(ii),sig2inv{ii}/phi(ii),ESS(ii));
                %lik_new(ii) = calculateLogLikelihood(obj{ii},trialsamps{ii});
            end
            alpha = min(1,exp(sum(lik_new)-sum(lik_old) + sum(lprior_new) - sum(lprior_old)),'includenan');


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
            
            
             
            %Delayed rejection (single stage)
            if acc(count) == 0 && drscale > 0 && ~isempty(qcov)

                %Reset to old at each step
                trialsamps2 = samps;
                trialparams2 = I_update;
                lprior_new2 = lprior_old;
                
                %trialparams2(count) = trialparams(count) + randn*propsteps(count);
                trialparams2(count) = I_update(count) + randn*propsteps(count)/drscale;
                trialsamps2{eNum}(sNum) = trialparams2(count);           

                % Proposal likelihood
                lik_new2 =zeros([1,Nexp]);
                
                for ii = 1:length(obj)
                    %Update shared variables
                    trialsamps2{ii}(obj{ii}.VariableSettings.Share) = trialsamps2{1}(obj{ii}.VariableSettings.Share);
                    lik_new2(ii) = calculateLogLikelihood(obj{ii},trialsamps2{ii},sig2{ii}*phi(ii),sig2inv{ii}/phi(ii),ESS(ii));
                    %lik_new2(ii) = calculateLogLikelihood(obj{ii},trialsamps2{ii});
                end
                
                %Prior likelihood
                lprior_new2(count) = priorfunc{count}(priorvals{count}{:},trialsamps{eNum}(sNum));
                
                

                % DR algorithm
                q1 = exp(-0.5*(norm((trialparams2-trialparams)*iR)^2-norm((I_update-trialparams)*iR)^2));
                alpha32 = min(1,exp(sum(lik_new)-sum(lik_new2) + sum(lprior_new) - sum(lprior_new2)),'includenan');
                L2 = exp(sum(lik_new2) + sum(lprior_new2) -sum(lik_old)-sum(lprior_old) );
                alpha13 = min(1, (L2*q1*(1-alpha32))/(1-alpha),'includenan');

                if rand <= alpha13
                    acc(count) = 1;  % Accept the candidate
                    savedsamps{eNum}(sNum) = trialsamps2{eNum}(sNum);
                    savedparams(count) = trialparams2(count);
                    savedpriors(count) = lprior_new2(count);
                else
                    acc(count) = 0; 
                end


            end %End of DR

        end %End of inferred variable check            
    end %End of variables loop
end %End of experiments loop

%Update the accepted values
samps = savedsamps;
I_update = savedparams;
lprior_old = savedpriors;


% Update the likelihood given final combination of accepted values
lik_old =zeros([1,Nexp]);
response_old = {lik_old};
for ii = 1:Nexp
    [lik_old(ii),response_old{ii},error_old{ii}] = calculateLogLikelihood(obj{ii},samps{ii},sig2{ii}*phi(ii),sig2inv{ii}/phi(ii),ESS(ii));
    %[lik_old(ii),response_old{ii}] = calculateLogLikelihood(obj{ii},samps{ii});
end
        
    
end %End individual update


%% %%%%%%%%%%%%%%%%%%%%%%%%%%  Hyperparameter, phi, Update %%%%%%%%%%%%%%%%%%
function HyperUpdate

% Conjugate prior update
if 1
    for ii = 1:Nexp  
        if isvector(sig2{ii});
            b1 = b0(ii) + 0.5*(ESS(ii)/numel(response_old{ii}))*sum((response_old{ii}./sqrt(sig2{ii})).^2);
        else
            b1 = b0(ii) + 0.5*(ESS(ii)/numel(response_old{ii}))*response_old{ii}'*sig2inv{ii}*response_old{ii};
        end
        a1 = a0(ii) + 0.5*ESS(ii);
        phi(ii) = InvGamma(a1,b1);   
    end
    
% Metropolis update    
else


    %Draw new samples from multivariate normal distrubtion with step sizes
    %given by proposal covariance.    
    trial_phi = phi + randn(size(phi))*R_phi;
    
    if trial_phi <= 0
        hyperacc(MCMCloop,1) = 0;
        return;
    end
        

    lphi_new = 0*phi;
    lik_new = zeros([1,Nexp]);
    for ii = 1:length(phi)
        %lphi_new = phi_priorfunc(phi_priorvals{:},trialphi);
        lphi_old(ii) = InvGamma(a0(ii),b0(ii),phi(ii));
        lphi_new(ii) = InvGamma(a0(ii),b0(ii),trial_phi(ii));
        lik_new(ii)  = calculateLogLikelihood(obj{ii},samps{ii},sig2{ii}*trial_phi(ii),sig2inv{ii}/trial_phi(ii),ESS(ii));
    end

    %Calculate alpha (update criteria)
    alpha = min(1,exp(sum(lik_new)-sum(lik_old) + sum(lphi_new) - sum(lphi_old)),'includenan');

    % Metropolis update
    if rand <= alpha
        phi = trial_phi;
        hyperacc(MCMCloop,1) = 1;
    else
        hyperacc(MCMCloop,1) = 0;
    end
    
    %Delayed rejection (single stage)
    if hyperacc(MCMCloop,1) == 0 && drscale > 0

        %Next step
        trial_phi2 = phi + randn(size(phi))*R_phi/drscale;
        
        if trial_phi2 <= 0
            hyperacc(MCMCloop,1) = 0;
            return;
        end
        
       
        % Proposal likelihood
        lik_new2 =zeros([1,Nexp]);
        for ii = 1:length(obj)
            lphi_new2(ii) = InvGamma(a0(ii),b0(ii),trial_phi2(ii));
            lik_new2(ii)  = calculateLogLikelihood(obj{ii},samps{ii},sig2{ii}*trial_phi2(ii),sig2inv{ii}/trial_phi2(ii),ESS(ii));
        end

        % DR algorithm
        q1 = exp(-0.5*(norm((trial_phi2-trial_phi)*iR_phi)^2-norm((phi-trial_phi)*iR_phi)^2));
        alpha32 = min(1,exp(sum(lik_new)-sum(lik_new2) + sum(lphi_new) - sum(lphi_new2)),'includenan');
        L2 = exp(sum(lik_new2) + sum(lphi_new2) -sum(lik_old)-sum(lphi_old));
        alpha13 = min(1, (L2*q1*(1-alpha32))/(1-alpha),'includenan');

        if rand <= alpha13
            phi = trial_phi2;
            hyperacc(MCMCloop,1) = 1;
        else
            hyperacc(MCMCloop,1) = 0;
        end
    end
    
    
    
    
    
end

end





end %%End runMCMC













