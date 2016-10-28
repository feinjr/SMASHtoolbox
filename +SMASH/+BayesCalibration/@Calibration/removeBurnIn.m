% remove burn-in from an MCMCResults chain
%
% Calculates the set of parameters which maximizes the likelihood function
%
%    >> object = removeBurnIn(object,burnin);
% 
% where burnin is the number of samples to remove from beginning of the
% chain. A negative value will trim values from the end.
%
% See also BayesCalibration, Calibration, runMCMC
% 

%
% created August 9, 2016 by Justin Brown (Sandia National Laboratories)
%
function object = removeBurnIn(object,burnin)

    assert(isscalar(burnin),'ERROR: burnin must be a scalar value');

    if burnin > 0
        object.MCMCResults.InferredChain = object.MCMCResults.InferredChain(burnin+1:end,:);
        object.MCMCResults.CutChain = object.MCMCResults.CutChain(burnin+1:end,:);
        object.MCMCResults.AcceptanceRate = object.MCMCResults.AcceptanceRate(burnin+1:end,:);
        object.MCMCResults.LogLikelihood = object.MCMCResults.LogLikelihood(burnin+1:end,:);
        object.MCMCResults.HyperChain = object.MCMCResults.HyperChain(burnin+1:end,:);
    else
        object.MCMCResults.InferredChain = object.MCMCResults.InferredChain(1:end+burnin,:);
        object.MCMCResults.CutChain = object.MCMCResults.CutChain(1:end+burnin,:);
        object.MCMCResults.AcceptanceRate = object.MCMCResults.AcceptanceRate(1:end+burnin,:);
        object.MCMCResults.LogLikelihood = object.MCMCResults.LogLikelihood(1:end+burnin,:);
        object.MCMCResults.HyperChain = object.MCMCResults.HyperChain(1:end+burnin,:);
    end

    
    
        
    
    
end
