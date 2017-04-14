classdef ShotSummary
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Shot
        Campaign
        Date
        HardwareSet
        LinerDimensions = [0.2325, 0.279];
        ImplodingHeight = 1;
        Cushions = {'Be','Be'};
        Dopants = 'none'
        FillPressure = 60;
        FillTemperature = 293;
        FieldStrength = 10;
        PhasePlate = 'none';
        LaserConfiguration = '';
        LaserEnergy = 2000;
        WindowThickness = 1.7;
        WindowOffset = 0.15;
        LinerCoating = { };
        
    end
    methods(Hidden=true)
        function object = ShotSummary(varargin)
            object.Shot = varargin{1};
        end
    end
    methods(Hidden=false)
        varargout = print(varargin);
        varargout = configure(varargin);
    end
    
end

