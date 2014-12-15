% under construction
classdef HarmonicOscillator
    properties 
        Mass = 1 % [kg]
        Stiffness = 1 % [N/m]
        Damping = 0 % 
        DriveFunction
        Velocity0 = 0 % 
        Position0 = 0 %
    end
    methods %(Hidden=true)
        function object=HarmonicOscillator(varargin)
        end
    end  
    %% setters
    methods
    end
end