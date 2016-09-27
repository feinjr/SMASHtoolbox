% Sample from the priors of the calibration object
%
% Calculates random samples (l) from the prior distribution
%
%    >> l = samplePriors(object);
% 
% If an array of prior values (x) is passed, the log-likelood and it's
% derivative are returned.
%
%    >> [l dl] = samplePriors(object,x);
%
% See also BayesCalibration, Calibration
% 

%
% created June 21, 2016 by Justin Brown (Sandia National Laboratories)
%
function [l,dl] = samplePriors(object,varargin)
% Error checking on object
nel = [numel(object.VariableSettings.Names),numel(object.VariableSettings.PriorType),numel(object.VariableSettings.PriorSettings)];
if (max(nel)-min(nel)) ~= 0 
    error('ERROR : object.VariableSettings must contain same number of elements for each field')
end

Narg=numel(varargin);
l=[]; dl = [];

%If no other inputs, sample from the distrubtions
if Narg == 0
    for i=1:nel(1)
        func = str2func(object.VariableSettings.PriorType{i});
        vals = num2cell(object.VariableSettings.PriorSettings{i});
        l(i) = func(vals{:});
    end
   
%If providing a logical vector to evaluate, only return samples indexed
elseif Narg == 1 && islogical(varargin{1})
    sampvar = find(varargin{1});
    for i=1:length(sampvar)
        func = str2func(object.VariableSettings.PriorType{sampvar(i)});
        vals = num2cell(object.VariableSettings.PriorSettings{sampvar(i)});
        l(i) = func(vals{:});
    end   
    
         
%If providing a vector to evaluate, return samples indexed
elseif Narg == 1 && isnumeric(varargin{1})
    sampvar = varargin{1};
    for i=1:length(sampvar)
        func = str2func(object.VariableSettings.PriorType{sampvar(i)});
        vals = num2cell(object.VariableSettings.PriorSettings{sampvar(i)});
        l(i) = func(vals{:});
    end
   
    
else
    error('ERROR : unsupported input');
            
end

end
