classdef HVPDV
    properties
        Measurement               
    end
    properties
        ClockRate
        Period
        NumberPulses
        PulseCenter
        PulseBound
    end
    methods (Hidden=true)
        function object=HVPDV(varargin)
            try
                object.Measurement=...
                    SMASH.SignalAnalysis.Signal(varargin{:});
            catch
                error('ERROR: invalid input');
            end
            object=align(object);
        end
    end
end