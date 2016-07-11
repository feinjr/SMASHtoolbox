function [newphi acc] = hyperUpdate(obj,lik_old,samps,sig,phi,drscale)
    newphi = phi;
    propstep = 0;
    acc = 0;
    
    priorfunc = str2func(obj{1}.VariableSettings.HyperSettings{1});
    priorvals = num2cell(obj{1}.VariableSettings.HyperSettings{2});
    trialphi = priorfunc(priorvals{:});
    
    if length(obj{1}.VariableSettings.HyperSettings) > 2 && isnumeric(obj{1}.VariableSettings.HyperSettings{3})
       % Sample from Gauss propstep
       propstep = obj{1}.VariableSettings.HyperSettings{3};
       trialphi = phi + Gauss(0,propstep);
    else
       % Sample from prior    
       trialphi = priorfunc(priorvals{:});
    end
    
    
    %Find new likelihoods
    lik_new =[];
    for i = 1:length(obj)
        lik_new(i) = calculateLogLikelihood(obj{i},samps{i},sig{i}*trialphi);
    end
    lprior_old = priorfunc(priorvals{:},phi);
    lprior_new = priorfunc(priorvals{:},trialphi);

    alpha = min(1,exp(sum(lik_new)-sum(lik_old) + lprior_new - lprior_old));

    if rand <= alpha
        newphi = trialphi;
        acc = 1;
        return
    end
    
    
    %Delayed rejection (single stage)
    if acc == 0 && drscale > 0 && propstep > 0

        trialphi2 = phi + Gauss(0,propstep/drscale);
        lik_new2 =[];
        for i = 1:length(obj)
            lik_new2(i) = calculateLogLikelihood(obj{i},samps{i},sig{i}*trialphi2);
        end
        lprior_new2 = priorfunc(priorvals{:},trialphi2);
        
       
        % Conditional priors
        %q32 = priorfunc(priorvals{:},[trialphi2,trialphi]);
        %q12 = priorfunc(priorvals{:},[phi,trialphi]);
        %q1 = exp(q32-q12);
    
        iR = drscale/propstep;
        q1 = exp(-0.5*(norm((trialphi2-trialphi)*iR)^2-norm((phi-trialphi)*iR)^2));
        
        
        % DR algorithm
        alpha32 = min(1,exp(sum(lik_new2)-sum(lik_new) + lprior_new2 - lprior_new));
        L2 = exp(sum(lik_new2) + lprior_new2 -sum(lik_old)-lprior_old );
        alpha13 = min(1, (L2*q1*(1-alpha32))./(1-alpha));
        if rand < alpha13
            acc = 1;
            newphi = trialphi2;
            return
        end
        

end


