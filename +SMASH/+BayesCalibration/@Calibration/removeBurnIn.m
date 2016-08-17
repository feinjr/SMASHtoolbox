% remove burn-in from an MCMCResults chain
%
% Calculates the set of parameters which maximizes the likelihood function
%
%    >> object = removeBurnIn(object,burnin);
% 
% where burnin is the number of samples to remove from beginning of the chain.
%
% See also BayesCalibration, Calibration, runMCMC
% 

%
% created August 9, 2016 by Justin Brown (Sandia National Laboratories)
%
function object = removeBurnIn(object,burnin)

    assert(isscalar(burnin),'ERROR: burnin must be a scalar value');

    object.MCMCResults.InferredChain = object.MCMCResults.InferredChain(burnin+1:end,:);
    object.MCMCResults.CutChain = object.MCMCResults.CutChain(burnin+1:end,:);
    object.MCMCResults.AcceptanceRate = object.MCMCResults.AcceptanceRate(burnin+1:end,:);
    object.MCMCResults.LogLikelihood = object.MCMCResults.LogLikelihood(burnin+1:end,:);
    object.MCMCResults.HyperChain = object.MCMCResults.HyperChain(burnin+1:end,:);

end
