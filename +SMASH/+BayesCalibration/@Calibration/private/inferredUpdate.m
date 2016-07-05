function [newsamp acc] = inferredUpdate(obj,lik_old,samps,eNum,sNum,sig,phi,drscale)

newsamp = samps{eNum}(sNum);
Nexp = length(samps);
trialsamps = samps;
acc = 0;
propstep = 0;

priorfunc = str2func(obj{eNum}.VariableSettings.PriorType{sNum});
priorvals = num2cell(obj{eNum}.VariableSettings.PriorSettings{sNum});

%Use Gaussian step if proposal is specified
if ~isempty(obj{eNum}.VariableSettings.ProposalStd) && isnumeric(obj{eNum}.VariableSettings.ProposalStd(sNum))
    propstep = obj{eNum}.VariableSettings.ProposalStd(sNum);
    trialsamps{eNum}(sNum) = samps{eNum}(sNum) + Gauss(0,propstep);
%Otherwise sample from prior
else
    trialsamps{eNum}(sNum) = priorfunc(priorvals{:});  
end


%Find likelihood of trial state
lik_new =[];
for i = 1:Nexp
    %Update shared variables
    trialsamps{i}(obj{i}.VariableSettings.Share) = trialsamps{1}(obj{i}.VariableSettings.Share);
    lik_new(i) = calculateLogLikelihood(obj{i},trialsamps{i},sig{i}*phi);
end

% Likelihood of priors
lprior_old = priorfunc(priorvals{:},samps{eNum}(sNum));
lprior_new = priorfunc(priorvals{:},trialsamps{eNum}(sNum));

alpha = min(1,exp(sum(lik_new)-sum(lik_old) + lprior_new - lprior_old));
%alpha = min(0,sum(lik_new)-sum(lik_old) + lprior_new - lprior_old);
   
if rand <= alpha
   acc = 1;  % Accept the candidate
   %prob = min(alpha,1);     % Accept with probability min(alpha,1)
   newsamp = trialsamps{eNum}(sNum);
   return
end


%Delayed rejection (single stage)
if acc == 0 && drscale > 0 && propstep > 0
    trialsamps2 = samps;
    
    %Use Gaussian step if proposal is specified
    if propstep > 0
        trialsamps2{eNum}(sNum) = samps{eNum}(sNum) + Gauss(0,propstep/drscale);
    %Otherwise sample from prior
    else
        trialsamps2{eNum}(sNum) = priorfunc(priorvals{:});  
    end
    

    lik_new2 =[];
    for i = 1:length(obj)
        %Update shared variables
        trialsamps2{i}(obj{i}.VariableSettings.Share) = trialsamps2{1}(obj{i}.VariableSettings.Share);
        lik_new2(i) = calculateLogLikelihood(obj{i},trialsamps2{i},sig{i}*phi);
    end
    
    % New prior
    lprior_new2 = priorfunc(priorvals{:},trialsamps2{eNum}(sNum));
    
    % Conditional priors
    %q32 = priorfunc(priorvals{:},[trialsamps2{eNum}(sNum),trialsamps{eNum}(sNum)]);
    %q12 = priorfunc(priorvals{:},[samps{eNum}(sNum),trialsamps{eNum}(sNum)]);
    %q1 = exp(q32-q12);
    
    iR = drscale/propstep;
    q1 = exp(-0.5*(norm((trialsamps2{eNum}(sNum)-trialsamps{eNum}(sNum))*iR)^2-norm((samps{eNum}(sNum)-trialsamps{eNum}(sNum))*iR)^2));
    
    % DR algorithm
    alpha32 = min(1,exp(sum(lik_new2)-sum(lik_new) + lprior_new2 - lprior_new));
    L2 = exp(sum(lik_new2) + lprior_new2 -sum(lik_old)-lprior_old );
    alpha13 = min(1, (L2*q1*(1-alpha32))./(1-alpha));
    if rand < alpha13
        acc = 1;
        newsamp = trialsamps2{eNum}(sNum);
        return
    end


end














%         
% 
%     % At this point don't allow different experiments to have different inferred variables 
%     keepsamps = samps; 
%     
% 
%     
%     % Metropolis Update for each inferred parameter
%     for ai = 1:length(ivars)
%         %Only update current variable
%         trialsamps = samps;
%         %Use Gaussian step if proposal is specified
%         if isnumeric(obj{1}.MCMCSettings.ProposalStep{ivars(ai)}) & ~isempty(obj{1}.MCMCSettings.ProposalStep{ivars(ai)})
%             propstep = obj{1}.MCMCSettings.ProposalStep{ivars(ai)};
%             trialsamps{1}(ivars(ai)) = trialsamps{1}(ivars(ai)) + Gauss(0,propstep);
%         %Otherwise sample from prior
%         else
%             trials = samplePriors(obj{1},addinferred{1});
%             trialsamps{1}(ivars(ai)) = trials(ai);  
%         end
% 
%         %Find new likelihoods
%         lik =[];
%         for i = 1:Nexp
%             trialsamps{i}(ivars(ai)) = trialsamps{1}(ivars(ai));
%             lik(i) = calculateLogLikelihood(obj{i},trialsamps{i},sig{i}*phi);
%         end
%         lprior_new = sum(samplePriors(obj{1},addinferred{1},trialsamps{1}));
%         lik_new = sum(lik);
% 
%         alpha = exp(lik_new-lik_old + lprior_new - lprior_old);
% 
%         if rand <= min(alpha,1)
%            accepted(ai) = accepted(ai) +1;  % Accept the candidate
%            %prob = min(alpha,1);     % Accept with probability min(alpha,1)
%             keepsamps{1}(ivars(ai)) = trialsamps{1}(ivars(ai));
%         else
%            %prob = 1-min(alpha,1);   % The same state with probability 1-min(alpha,1)
%         end
%     end
%     
%     % Metropolis update for hyperparameters
%         trialphi = InvGamma(104,103);
%                 %Find new likelihoods
%         lik =[];
%         for i = 1:Nexp
%             lik(i) = calculateLogLikelihood(obj{i},samps{i},sig{i}*trialphi);
%         end
%         philik = InvGamma(104,103,phi)-InvGamma(104,103,trialphi);
%         lik_new = sum(lik);
%         
%         alpha = exp(lik_new-lik_old + philik);
%         if rand <= min(alpha,1)
%             phi = trialphi;
%         end
%         hyperchain = vertcat(hyperchain,phi);