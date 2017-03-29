%
%    object=add(object,record,offset,wavelength)
%    "record" can be a 2-3 column table.
%    "offset" must be a scalar (positive or negative)
%    "wavelength" must also be a scalar
%
%    object=add(object,source); % source PDV object
%    object=add(object,source1,source2,...)

function object=add(object,varargin)

% manage input
assert(nargin > 1,'ERROR: insufficient input');

if isa(varargin{1},'SMASH.Velocimetry.PDV')    
    for n=1:numel(varargin)        
        frequency=object.Frequency{1};
        uncertainty=object.FrequencyUncertainty{1};
        if ischar(uncertainty)
            uncertainty=frequency;
            uncertainty=reset(uncertainty,[],nan(size(uncertainty.Data)));
        end
        table=[frequency.Grid frequency.Data uncertainty.Data];
        offset=object.ReferenceFrequency;
        wavelength=object.Wavelength;
        object=add(object,table,offset,wavelength);        
    end
    return
elseif isa(varargin{1},'SMASH.SignalAnalysis.Signal')
    data=varargin{1}.Data;
    if size(data,2)==1
        data(:,2)=nan;
    elseif size(data,2) > 2
        data=data(:,1:2);
    end       
    table=[varargin{1}.Grid data];        
    [offset,wavelength]=parseOptions(varargin{2:end});
elseif ismatrix(varargin{1})
    table=varargin{1};
    if size(table,2)==2
        table(:,3)=nan;    
    end
    assert(size(table,2) == 3,'ERROR: invalid number of table columns');
    [offset,wavelength]=parseOptions(varargin{2:end});
else
    error('ERROR: invalid input');
end




end

function [offset,wavelength]=parseOptions(varargin)

if (nargin < 1) || isempty(varargin)
    offset=0;
end
assert(isnumeric(offset) && isscalar(offset),'ERROR: invalid offset value');

if (nargin<2) || isempty(varargin)
    wavelength=1550e-9;
end
assert(isnumeric(wavelength) && isscalar(wavelength),'ERROR: invalid wavelength value');

end