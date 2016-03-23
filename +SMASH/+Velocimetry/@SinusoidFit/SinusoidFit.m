% UNDER CONSTRUCTION
%
% object=SinusoidFit(time,signal,tolerance)
%
classdef SinusoidFit
    %%
    properties (SetAccess=protected) % inputs
        Time
        Signal
        BreakTolerance = inf
        FrequencyBound
        Basis
        Curve
    end    
    properties (SetAccess=protected) % outputs
        Domains
        StartTime
        StopTime
        Amplitude
        Frequency
        Chirp
    end
    %%
    methods (Hidden=true)
        function object=SinusoidFit(varargin)
            object=reset(object,varargin{:});
        end
    end
    %%
    methods (Static=true, Hidden=true)
        function object=restore(data)
            error('ERROR: restore method has not been enabled yet for this class');
        end
    end  
end