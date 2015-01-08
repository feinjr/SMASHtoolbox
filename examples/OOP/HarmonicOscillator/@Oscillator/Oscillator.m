% Simple harmonic oscillator class
classdef Oscillator
    %%
    properties 
        InitialPosition = 0 % initial position
        InitialVelocity = 0 % initial velocity
        Mass = 1 % mass
        Stiffness = 1 % spring constant 
        Damping = 0 % damping coefficient
    end
    properties (Hidden=true)
        Options % ODE options
    end
    %%
    methods (Hidden=true)
        function object=Oscillator(varargin)
            fprintf('Oscillator object created\n');
        end
    end
    %%
    methods (Access=protected,Hidden=true)
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
            assert(value>=0,'ERROR: invalid Stiffness');
            object.Stiffness=value;
        end
        function object=set.Damping(object,value)
            assert(testValue(value),'ERROR: invalid Damping');
            assert(value>=0,'ERROR: invalid Damping');
            object.Damping=value;
        end            
    end
end