%
%
% created May 9, 2017 by Patrick Knapp (Sandia National Laboratories)
%
classdef MLM
    %% properties
    properties % core data
        Measurement     % image object
        Linearized      % image object
        Frames          % imagegroup object
        RegisteredImages      % Imagegroup object
        Settings    % structure containing pertinent information
        Wedge       % StepWedge object for calibrating film
    end
    
    %% constructor
    methods (Hidden=true)
        function object=MLM(varargin)
            p = struct();
            p.Shot = [];
            p.Times = [];
            p.Magnification = 0.5;
            p.Camera = 'C';
            p.Energy = 'Broadband';
            p.Pinhole = 50; %microns
            p.NumberImages = 8;
            p.FilterMaterial  = 'Kapton';
            p.FilterThickness = 25.4*2.0/3.0; %mcirons
            p.Detector = 'film';
            p.ReferenceImage = 1;
            p.Shifts = [];
            
            object.Settings = p;
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=varargin{1};
                object.Measurement=varargin{1};
            elseif (nargin == 2) && ischar(varargin{1}) && ischar(varargin{2})
                object.Measurement=SMASH.ImageAnalysis.Image(varargin{1},varargin{2});
            end
            object.Measurement.GraphicOptions.YDir = 'normal';
            object.Measurement.GraphicOptions.AspectRatio = 'equal';
        end
    end
    methods (Static=true)
        varargout = correctMagnification(varargin)
        varargout = calibrateIntensity(varargin)
        varargout = correctBackground(varargin)
        varargout = restore(varargin);
        varargout = registerImages(varargin);
        varargout = viewproperties(varargin)
        
    end
    
end