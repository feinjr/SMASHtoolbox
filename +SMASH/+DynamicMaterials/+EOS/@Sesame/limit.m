% LIMIT Limit object to a region of interest
%
% This method defines a density region of interest in a Sesame object,
% limiting the range used in calculations and visualization.
%
% Usage:
%     >> object=limit(object,[lower upper]); % specify Grid range
%     >> object=limit(object,'all');
%
% Calling this method with the object input only:
%    >> [density,temperature,pressure,energy,entropy,data]=limit(object);
% returns arrays from the limited region.
%
% See also Sesame
%

% created April 25, 2014 by Justin Brown (Sandia National Laboratories)

function varargout=limit(object,bound)

% handle input
if nargin==1
    data = [];
    %No limit
    if strcmp(object.LimitIndex,'all')
        density=object.Density;
        temperature=object.Temperature;
        pressure = object.Pressure;
        energy = object.Energy;
        entropy = object.Entropy;
        for i =1:length(object.Data)
            data{i} = object.Data{i};
        end
    %Limit    
    else
        density=object.Density(object.LimitIndex);
        temperature=object.Temperature(object.LimitIndex);
        pressure = object.Pressure(object.LimitIndex);
        energy = object.Energy(object.LimitIndex);
        entropy = object.Entropy(object.LimitIndex);
        for i =1:length(object.Data)
            data{i} = object.Data{i}(object.LimitIndex);
        end
    end
    %Assign output variables
    varargout{1}=density;
    varargout{2}=temperature;
    varargout{3}=pressure;
    varargout{4}=energy;
    varargout{5}=entropy;
    for i=1:length(data)
        varargout{i+5}=data{i};
    end
    return
end

% apply limit bound
if strcmpi(bound,'all')
    object.LimitIndex='all';
elseif isnumeric(bound) && (numel(bound)==2)    
    keep=(object.Density>=bound(1)) & (object.Density<bound(2));
    index=1:numel(object.Density);
    object.LimitIndex=index(keep);
else
     error('ERROR: invalid limit bound');
end

if isnumeric(object.LimitIndex)
    match=strcmpi(class(object.LimitIndex),object.Precision);
    if ~match
        object.LimitIndex=feval(object.Precision,object.LimitIndex);
    end            
end

% handle output
varargout{1}=object;

end