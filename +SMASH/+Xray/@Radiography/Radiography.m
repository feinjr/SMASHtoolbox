
% This class creates Radiography objects from ZBL backlighter image plate
% records.  It is a subclass of SMASH.ImageAnalysis.Image
%
% A Radiography object is created:
%   >> object=Radiography();
%
% See also Xray, Image
%
%
% created May 27, 2014 by Patrick Knapp (Sandia National Laboratories)
%
classdef Radiography
    %% properties
    properties % core data
        Measurement
        Transmission
        Density
    end
    properties
        Settings
    end
    
    
    %% constructor
    methods (Hidden=true)
        function object=Radiography(varargin)
            p = struct();
            p.Magnification = [5.9642, 5.7736];
            p.Shot = 9999;
            p.Frame = [];
            p.Time = [];
            p.PhotonEnergy = 6151; %Standard ZBL Backlighter Energy in eV
            p.Opacity = 2.2392; % Be Opacity at 6151 eV in cm^2/g
            
            object.Settings = p;
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=SMASH.ImageAnalysis.Image(varargin{1});
                object.Measurement=varargin{1};
            elseif (nargin == 2) && ischar(varargin{1}) && ischar(varargin{2})
                object.Measurement=SMASH.ImageAnalysis.Image(varargin{1},varargin{2});
            end
            object.Measurement.GraphicOptions.LineColor = 'm';
            object.Measurement.GraphicOptions.LineStyle = '--';
            object.Measurement.GraphicOptions.YDir = 'normal';
        end
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
  
    methods (Hidden=false)
        varargout=calibrateTransmission(varargin)
        varargout=subtractBackground(varargin)
        varargout=svd_surface(varargin)
        varargout=abelInvert(varargin)
    end
end