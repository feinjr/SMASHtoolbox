% Calculates the log likelihood
%
%    >> object=calculateLogLikelihood(object,x)
% 
% where x is the parameter input to the model.
%
% If the covariance is known, the likelihood calculation can be speed up:
%
%     >> object=calculateLogLikelihood(object,x,sig2)
%
% See also BayesCalibration, Calibration, runMCMC
% 

%
% created June 21, 2016 by Justin Brown (Sandia National Laboratories)
%
function l = calculateLogLikelihood(object,x,sig2)



if nargin > 2
    %r = calculateResiduals(object,x);
    r = object.ModelSettings.Model(object,x);
else
    %[r,sig2] = calculateResiduals(object,x);
    [r,sig2] = object.ModelSettings.Model(object,x);
end

n = length(r);
%Assume diagonal for speedup
if isvector(sig2);
    %sig2 = diag(sig2);
    %l = -sum(((r./1).^2)./(2.*sig2) + 0.5*log(sig2));
    l = -sum(((r./1).^2)./(2.*sig2) -n/2*log(2*pi) + 0.5*log(sig2));
else 
    sig2inv = inv(sig2);
    %l = 0.5*r'*sig2inv*r + n/2*log(2*pi)+0.5*log(det(sig));
    %l = -0.5*r'*sig2inv*r -sum(log(diag(chol(sig2))));
    l = -0.5*r'*sig2inv*r - n/2*log(2*pi) - sum(log(diag(chol(sig2))));
end




end
