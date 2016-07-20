% Evaluate the priors of the calibration object
%
% Calculates the log-likelihood and it's derivative for the  array of 
% values (x):
%
%    >> [l dl] = samplePriors(object,x);
%
% See also BayesCalibration, Calibration
% 

%
% created June 21, 2016 by Justin Brown (Sandia National Laboratories)
%
function [l,dl] = evaluatePriors(object,varargin)
% Error checking on object
nel = [numel(object.VariableSettings.Names),numel(object.VariableSettings.PriorType),numel(object.VariableSettings.PriorSettings)];
if range(nel) ~= 0 
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
    
         
%If providing a vector to evaluate, return the log-likelihood and it's
%derivative
elseif Narg == 1 && isnumeric(varargin{1})
    for i=1:nel(1)
        func = str2func(object.VariableSettings.PriorType{i});
        vals = num2cell([object.VariableSettings.PriorSettings{i},varargin{1}(i)]);
        [lt,dlt] = func(vals{:});
        l(i) = lt;
        dl(i) = dlt;
    end
   
%If providing logical vector followed by array, return log-likelihood and
%it's derivative of the indexed samples
elseif Narg == 2 && islogical(varargin{1}) && isnumeric(varargin{2})
    sampvar = find(varargin{1});
    vars = varargin{2};
    for i=1:length(sampvar)
        func = str2func(object.VariableSettings.PriorType{sampvar(i)});
        vals = num2cell([object.VariableSettings.PriorSettings{sampvar(i)},vars(i)]);
        [lt,dlt] = func(vals{:});
        l(i) = lt;
        dl(i) = dlt;
    end
    
    
%If providing 2 arrays of vector values, assume first indexes priors and
%second are values to evaluate at
elseif Narg == 2 && isnumeric(varargin{1}) && isnumeric(varargin{2})
    sampvar = varargin{1};
    vars = varargin{2};
    for i=1:length(sampvar)
        func = str2func(object.VariableSettings.PriorType{sampvar(i)});
        vals = num2cell([object.VariableSettings.PriorSettings{sampvar(i)},vars(i)]);
        [lt,dlt] = func(vals{:});
        l(i) = lt;
        dl(i) = dlt;
    end        

    
else
    error('ERROR : unsupported input');
            
end

end
