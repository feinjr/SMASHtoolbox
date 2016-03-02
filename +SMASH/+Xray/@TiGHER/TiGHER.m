%
%
% created February 4, 2016 by Patrick Knapp (Sandia National Laboratories)
%
classdef TiGHER
    %% properties
    properties % core data
        Measurement % image object
        Linearized
        frames % Cell array of image objects
    end
    properties
        Settings    % structure containing pertinent information
        Wedge       % StepWedge object for calibrating film
    end
    
    %% constructor
    methods (Hidden=true)
        function object=TiGHER(varargin)
            p = struct();
            p.Shot = [];
            p.Magnification = 0.8;
            p.Orientation = 'AR';
            p.Crystal = 'Quartz 1011';
            p.SlitWidth = 100; %microns
            p.FilterMaterial = {'Kapton','Be','Quartz'};
            p.FilterThickness = [1500, 5000, 100]; %mcirons
            p.Detector = 'plate';
            p.Angle = 8.5; %crystal rotation angle in degrees
            p.Curvature = 250; %Radius of curvature in mm
            p.Transmission = [];
            
            object.Settings = p;
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=varargin{1};
                object.Measurement=varargin{1};
            elseif (nargin == 2) && ischar(varargin{1}) && ischar(varargin{2})
                object.Measurement=SMASH.ImageAnalysis.Image(varargin{1},varargin{2});
            end
        end
    end
    methods (Static=true)
        varargout = calibrateScale(varargin)
        varargout = calibrateIntensity(varargin)
        varargout = subtractBackground(varargin)
        varargout = totate(varargin);
        varargout = correctTransmission(varargin);
        varargout = restore(varargin);
    end
    
end