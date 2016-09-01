classdef HVPDV
    properties
        Measurement % Measured (x,y) data [Signal object]              
        SampleRate
        SamplePeriod
    end
    properties
        ClockRate
        ClockPeriod
        NumberPulses
        PulseCenter
        PulseBound
        PulseShape  
        HilbertCutoff= 0.1e9 
    end
    properties
        MaxCrossings=2; % maximum number of crossings
    end
    %%
    methods (Hidden=true)
        function object=HVPDV(varargin)
            try
                object.Measurement=...
                    SMASH.SignalAnalysis.Signal(varargin{:});
            catch
                error('ERROR: invalid input');
            end
            object.Measurement=regrid(object.Measurement); % enforce uniform sampling
            object=align(object);            
        end
        %varargout=align(varargin);
    end
end