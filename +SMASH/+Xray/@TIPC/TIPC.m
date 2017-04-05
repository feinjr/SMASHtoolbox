classdef TIPC
% This class creates TIPC objects from image plate
% records.  It contains Image and ImageGroup objects.  The
% object.Measurement property contains the full image.  The object.Images 
% property is an ImageGroup object containing each segmented image.  The
% object.RegisteredImages property is an ImageGroup object containg the
% registered images.  The object.Settings property contains pertinent
% instrument and shot information.
%
% A TIPC object is created in one of several ways:
%   >> object=TIPC(filename,'plate');
%           This will read the image plate data into the measurement
%           property.  Further processing is required to populate the other
%           properties
%
%   >> object = TIPC(imageobject)
%           This will take an existing image object and populate the
%           measurement property
%
%   The basic workflow is as follows:
%       1.  Create the TIPC object from image plate data or an existing
%           object.  Correct for magnification (this is important!)
%       2.  Populate the settings to ensure correct information
%       3.  Divide the raw image into individual images using the
%           segmentImages method
%       4.  Correct the background exposure for each image using the
%           correctBackground method
%       5.  Register each image to one chosen by the user as a reference
%           image (default is image 1).
%       6.  Create a summary of the images by binning the image into
%           Nslices axial slices and integrating radially.  The sumamry
%           includes an estimate of the uncertainty in the integrated
%           intensity values.
%
% See also Xray, Image, Radiography
% created March 1, 2017 by Patrick Knapp (Sandia National Laboratories)
%
%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           Image Order:
    %       5   3   1   2   4
    %       |   |   |   |   |
    % notch
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        Measurement
        Settings
        Images
        RegisteredImages
        Summary
    end
    
    %% constructor
    methods(Hidden=true)
       function object=TIPC(varargin)
            p = struct();
            p.Shot = 9999;
            p.DecayTime = 720;  % minutes from shot time to scan time
            
            p.PinholeDiameter = 0.005;  % cm
            p.SourcetoPinholeDistance = 25.4;   % cm
            p.PinholetoDetectorDistance = 9.65;  % cm
            p.Detector = 'Image Plate';
            p.NumberImages = 5;
            p.Magnification = p.PinholetoDetectorDistance/p.SourcetoPinholeDistance;
            p.ReferenceImage = 1;
            p.Nslices = 20;           
            p.Shifts = [];
            
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
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
  
    methods (Hidden=false)
        varargout=segmentImages(varargin)
        varargout=correctBackground(varargin)
        varargout=registerImages(varargin)
        varargout=binImages(varargin)
        varargout=exportSummary(varargin)
        varargout = viewproperties(varargin)
    end
    
end

