% under construction
classdef SimpleHarmonicOscillator
    %%
    properties 
        InitialPosition = 0 % Initial position
        InitialVelocity = 0 % Initial velocity
        Mass = 1 % [kg]
        Stiffness = 1 % [N/m]
        Damping = 0 % 
    end
    %%
    methods (Hidden=true)
        function object=SimpleHarmonicOscillator(varargin)
            % nothing to do (yet)
        end
    end
    %%
    methods (Access=protected)
        varargout=calculateDerivatives(varargin)
    end
    %% setters
    methods
        function object=set.InitialPosition(object,value)
            assert(testValue(value),'ERROR: invalid InitialPosition');
            object.InitialPosition=value;
        end
        function object=set.InitialVelocity(object,value)
            assert(testValue(value),'ERROR: invalid InitialVelocity');
            object.InitialVelocity=value;
        end
        function object=set.Mass(object,value)
            assert(testValue(value),'ERROR: invalid Mass');
            assert(value>0,'ERROR: invalid Mass');
            object.Mass=value;
        end
        function object=set.Stiffness(object,value)
            assert(testValue(value),'ERROR: invalid Stiffness');
            assert(value>=0,'ERROR: invalid Mass');
            object.Stiffness=value;
        end
        function object=set.Damping(object,value)
            assert(testValue(value),'ERROR: invalid Damping');
            assert(value>0,'ERROR: invalid Damping');
            object.Damping=value;
        end            
    end
end