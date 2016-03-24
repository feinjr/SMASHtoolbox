% UNDER CONSTRUCTION
%
% object=SinusoidFit(time,signal,tolerance)
%
classdef SinusoidFit
    %%
    properties (SetAccess=protected) % inputs
        Time % Measurement time (numeric array)
        Signal % Measured signal (numeric array)
        BreakTolerance = inf % Domain break tolerance (scalar)
        FrequencyBound % Sinusoid frequency bound (cell array of BoundingCurve objects)
        Basis
        Curve % Optimized sinusoid curve
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
            if nargin==0
                return
            end
            object=reset(object,varargin{:});
        end
    end
    %%
    methods (Static=true, Hidden=true)
       varargou=restore(varargin)
    end  
end