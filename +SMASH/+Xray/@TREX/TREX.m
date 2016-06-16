%
%
% created February 4, 2016 by Patrick Knapp (Sandia National Laboratories)
%
classdef TREX
    %% properties
    properties % core data
        Measurement % image object
        Linearized
        frames = cell(6,1);% Cell array of image objects
    end
    properties
        Settings    % structure containing pertinent information
        Wedge       % StepWedge object for calibrating film
    end
    
    %% constructor
    methods (Hidden=true)
        function object=TREX(varargin)
            p = struct();
            p.Shot = [];
            p.Magnification = 1.0/3.0;
            p.Orientation = 'RR';
            p.Crystal = 'PET-T';
            p.SlitWidth = 100; %microns
            p.FilterMaterial  = 'Kapton';
            p.FilterThickness = 25.4*2.0/3.0; %mcirons
            p.Detector = 'film';
            
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
        varargout = rotate(varargin);
        varargout = correctTransmission(varargin);
        varargout = restore(varargin);
    end
    
end