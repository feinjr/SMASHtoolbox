% Thin the variables used to build the Gaussian Process
%
% This thins the variables used to build the Gaussian Process.
%
%    >> object=thinVariables(object,x);
% 
% If x is 1D array then it represents the elements to kept.  
% If x is a scalar, then it is taken to be a stride such that the 
% build points kept are 1:x:end
%
% See also GP, evaluate
% 

%
% created June 20, 2016 by Justin Brown (Sandia National Laboratories)
%
function object=thinVariables(object,x)

if ~isvector(x) && ~isscalar(x)
    error('ERROR : x must be a scalar or 1D array');
end

    
if isscalar(x)
    [nrow ncol] = size(object.VariableData);
    thin = 1:x:ncol;
    object.VariableData = object.VariableData(:,thin);
    object.VariableNames = object.VariableNames(thin);
else
    thin = x;
    object.VariableData = object.VariableData(:,thin);
    object.VariableNames = object.VariableNames(thin);
end


[nbuild nvars] = size(object.VariableData);
object.NumberVariables = nvars;
object.Settings.Theta0 = ones(1,object.NumberVariables);
object.Settings.Theta0_LowerBound = ones(1,object.NumberVariables)*1e-4;
object.Settings.Theta0_UpperBound = ones(1,object.NumberVariables)*1e4;


end
