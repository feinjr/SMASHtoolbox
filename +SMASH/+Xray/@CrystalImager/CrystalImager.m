classdef CrystalImager
% This class creates CrystalImager objects from image plate
% records or numerical data input. 
%
%
% See also Xray, Image, Radiography
% created March 6, 2017 by Patrick Knapp (Sandia National Laboratories)
%
%%
    properties
        Measurement
        Settings
        Image
        Summary
    end
    
    %% constructor
    methods(Hidden=true)
       function object=CrystalImager(varargin)
            p = struct();
            p.Shot = 9999;
            p.DecayTime = 720;  % minutes from shot time to scan time
            p.Detector = 'Image Plate';
            p.Magnification = 5.8;
            p.Nslices = 20;           
            p.BraggAngle = 82.91;
            p.Crystal = 'Ge 220';
            
            p.Filters = struct();
            p.Filters.Material = {'Kapton', 'Beryllium'};
            p.Filters.Thickness = {500, 50};     % um
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
            object.Measurement.Grid1Label = 'Radial Distance [cm]';
            object.Measurement.Grid2Label = 'Axial Distance [cm]';
            object.Measurement.DataLabel = 'Exposure';

        end
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
  
    methods (Hidden=false)
        varargout=correctBackground(varargin)
        varargout=summarize(varargin)
        varargout=exportSummary(varargin)
        varargout = viewproperties(varargin)
    end
    
end

