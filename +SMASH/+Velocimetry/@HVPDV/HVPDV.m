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
            %
            fprintf('Locating pulses...');
            object=align(object);      
            fprintf('done\n');
            %
            fprintf('Determining average pulse shape...');
            object=characterize(object);
            fprintf('done\n');
        end
        %varargout=align(varargin);
    end
end