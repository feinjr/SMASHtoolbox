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
function l = calculateLogLikelihood(object,x,varargin)

if nargin > 1
    sig2 = varargin{1};
    r = calculateResiduals(object,x);
else
    [r sig2] = calculateResiduals(object,x);
end

%siginv = inv(sig);
%n = length(r);
%l = 0.5*r'*siginv*r + n/2*log(2*pi)+0.5*log(det(sig));
%l = -0.5*r'*siginv*r - n/2*log(2*pi)-sum(log(diag(chol(sig))));
%l = -0.5*r'*siginv*r -sum(log(diag(chol(sig))));
%sig = diag(sig);
l = -sum(((r./1).^2)./(2.*sig2) + 0.5*log(sig2));

end
