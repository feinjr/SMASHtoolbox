classdef HVPDV
    properties
        Measurement               
        SampleRate
        SamplePeriod
    end
    properties
        ClockRate
        ClockPeriod
        NumberPulses
        PulseCenter
        PulseBound
    end
    properties
        MaxCrossings=2; % maximum number of crossings
        AreaThreshold=0.10; % fractional area threshold for m>1 crossings
        RemoveBoundary=0; % fractional duration removed from each side of a crossing
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