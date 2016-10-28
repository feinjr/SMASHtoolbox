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
function [l,r,er] = calculateLogLikelihood(object,x,sig2,R_sig2)

%Check constraints
if ~isempty(object.VariableSettings.ConstraintSettings)
    cfunc = object.VariableSettings.ConstraintSettings{2};
    cvarnums = object.VariableSettings.ConstraintSettings{1};
    constraint = cfunc(x(cvarnums));
    
    if ~constraint
        r = object.ModelSettings.Model(object,x);
        l = -inf;
        r = -inf*abs(r);
        er = -inf*abs(sig2);
        return;
    end
end

if nargin < 3
    [r,sig2] = object.ModelSettings.Model(object,x);
else
    %r = calculateResiduals(object,x);
    r = object.ModelSettings.Model(object,x);
end

if nargin < 4
    if isvector(sig2)
        R_sig2 = chol(diag(sig2));
    else
        R_sig2 = chol(sig2);
    end
end
    
% Speed up if diagonal
%n = length(r);
if isvector(sig2);
    l = -sum(((r./1).^2)./(2.*sig2) + 0.5*log(sig2));
    %l = -sum(((r./1).^2)./(2.*sig2) + 0.5*log(sig2)) -n/2*log(2*pi);
else 
    % Older formulations
    %l = 0.5*r'*sig2inv*r + n/2*log(2*pi)+0.5*log(det(sig));
    %l = -0.5*r'*sig2inv*r -sum(log(diag(chol(sig2))));
    %l = -0.5*r'*sig2inv*r - n/2*log(2*pi) - sum(log(diag(chol(sig2))));\
    
    z = R_sig2\r;
    l = -0.5*z'*z - sum(log(diag(R_sig2)));  
end


if nargout > 2
    if isvector(sig2);    
        er = sqrt(sig2);
    else 
        er = sqrt(diag(sig2));
    end
end    

end
