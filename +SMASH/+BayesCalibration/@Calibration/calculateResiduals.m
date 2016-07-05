% Calculate the object residuals
%
% Calculates the difference between the measurement and the model for the
% array of input parameters
%
%    >> [r sig2] = calculateResiduals(object,x);
% 
% where r are the residuals, sig2 is the covariance, and x are the inputs to
% the calibration object. This method simply evaluates the function handle
% located in object.ModelSettings.Model at x. It is up to the user to
% return r and sig2 from the function handle.
%
% See also BayesCalibration, Calibration, runMCMC
% 

%
% created June 21, 2016 by Justin Brown (Sandia National Laboratories)
%
function varargout = calculateResiduals(object,x)

if ~isvector(x)
    error('ERROR : x must be a 1D array');
end

if nargout == 1
    r = object.ModelSettings.Model(object,x);
    varargout{1} = r; 
elseif nargout == 2
    [r sig2] = object.ModelSettings.Model(object,x);
    varargout{1} = r; 
    varargout{2} = sig2; 
else
    error('ERROR : Invalid number of outputs');
end
