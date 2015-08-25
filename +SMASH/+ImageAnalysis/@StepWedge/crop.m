
function object=crop(object,varargin)

% manage input
if numel(varargin)==0
    varargin{1}='manual';
end

object.Measurement=crop(object.Measurement,varargin{:});

end