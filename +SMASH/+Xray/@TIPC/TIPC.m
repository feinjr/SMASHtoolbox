classdef TIPC
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Measurement
        Settings
        Images
    end
    
    %% constructor
    methods(Hidden=true)
       function object=TIPC(varargin)
            p = struct();
            p.Shot = 9999;
            p.PinholeDiameter = 0.005;  % cm
            p.SourcetoPinholeDistance = 25.4;   % cm
            p.PinholetoDetectorDistance = 9.65;  % cm
            p.Detector = 'Image Plate';
            p.Filters = struct();
            
            p.Filters.Material = struct('a',{'Kapton', 'Titanium'}, 'b', {'Kapton', 'Iron'},...
                'c', {'Kapton', 'Nickel'}, 'd', {'Kapton', 'Zinc'}, 'e', {'Kapton', 'Titanium'});
            p.Filters.Thickness = struct('a', {1500, 25}, 'b', {1500, 25}, 'c', {1500, 20}, 'd', {1500,20}, 'e', {1500, 75});     % um
            
            object.Settings = p;
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=SMASH.ImageAnalysis.Image(varargin{1}.Grid1,varargin{1}.Grid2,varargin{1}.Data);
                object.Measurement=varargin{1};
            elseif (nargin == 2) && ischar(varargin{1}) && ischar(varargin{2})
                object.Measurement=SMASH.ImageAnalysis.Image(varargin{1},varargin{2});
            end
            object.Measurement.GraphicOptions.LineColor = 'm';
            object.Measurement.GraphicOptions.LineStyle = '--';
            object.Measurement.GraphicOptions.YDir = 'normal';
        end
    end
    
end

