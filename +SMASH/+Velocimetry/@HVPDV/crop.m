% UNDER CONSTRUCTION

function object=crop(object,varargin)

try
    object.Measurement=crop(object.Measurement,varargin{:});
catch
    error('ERROR: invalid crop request');
end

object.NumberPulses=[];
object.PulseCenter=[];
object.PulseBound=[];
object.PulseShape=[];


end