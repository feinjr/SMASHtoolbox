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
function [l,r] = calculateLogLikelihood(object,x,sig2,sig2inv)



if nargin > 3
    %r = calculateResiduals(object,x);
    r = object.ModelSettings.Model(object,x);
elseif nargin > 2
    r = object.ModelSettings.Model(object,x);
    if isvector(sig2)
         sig2inv = inv(diag(sig2));
    else
        sig2inv = inv(sig2);
    end
else
    %[r,sig2] = calculateResiduals(object,x);
    [r,sig2] = object.ModelSettings.Model(object,x);
    if isvector(sig2)
         sig2inv = inv(diag(sig2));
    else
        sig2inv = inv(sig2);
    end   
end

n = length(r);
% Speed up if diagonal
if isvector(sig2);
    l = -sum(((r./1).^2)./(2.*sig2) + 0.5*log(sig2));
    %l = -sum(((r./1).^2)./(2.*sig2) + 0.5*log(sig2)) -n/2*log(2*pi);
else 
    %l = 0.5*r'*sig2inv*r + n/2*log(2*pi)+0.5*log(det(sig));
    l = -0.5*r'*sig2inv*r -sum(log(diag(chol(sig2))));
    %l = -0.5*r'*sig2inv*r - n/2*log(2*pi) - sum(log(diag(chol(sig2))));  
end

end
