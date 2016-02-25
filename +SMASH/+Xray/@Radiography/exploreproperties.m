function varargout = exploreproperties( object,varargin )
% This function is used to explore images of the various properties.  IT is
% similar to viewproperties except it opens an explore window, allowing the
% user to specify the caxis limits and the number of pixels in the x- and
% y-directions to average over for a lineout
%
%   Input Arguments:
%       varargin{1}: viewing option.  Specify which property to view
%       varargin{2}: Color axis limits
%       varargin{3}: 2x1 array specifying the No. of x and y pixels for
%       averaging of lineouts.  If none specified, 0 is used, which is the
%       same as slice.
Narg=numel(varargin);
clims = [];
xOff = 0;
yOff = 0;

if Narg == 0
    view(object.Measurement)
elseif Narg == 1
    option = varargin{1};
elseif Narg == 2
    option = varargin{1};
    clims = varargin{2};
elseif Narg == 3
    option = varargin{1};
    clims = varargin{2};
    xOff = varargin{3}(1);
    yOff = varargin{3}(2);

end
switch option
    case 'Data'
        obj = object.Measurement;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Raw Radiograph';
        obj.GraphicOptions.YDir = 'normal';
        LineoutWidth(obj,xOff,yOff,clims)
    case 'Transmission'
        obj = object.Transmission;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Transmission';
        obj.GraphicOptions.Title = 'Transmission';
        obj.GraphicOptions.YDir = 'normal';
        if isempty(clims)
            clims = [-0.1 1.1];
        end
        LineoutWidth(obj,xOff,yOff,clims)
    case 'Optical Depth'
        temp = object.Transmission.Data;
        temp(temp<1e-3) = 1e-3;
        
        temp = -log(temp);
        obj = SMASH.ImageAnalysis.Image(object.Transmission.Grid1,object.Transmission.Grid2,temp);
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Optical Depth';
        obj.GraphicOptions.Title = 'Optical Depth';
        obj.GraphicOptions.YDir = 'normal';
        if isempty(clims)
            clims = [-0.1 5];
        end
        LineoutWidth(obj,xOff,yOff,clims)
    case 'Opacity'
        temp = object.Transmission.Data;
        temp(temp<1e-3) = 1e-3;
        
        temp = -log(temp)/object.Settings.Opacity;
        obj = SMASH.ImageAnalysis.Image(object.Transmission.Grid1,object.Transmission.Grid2,temp);
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Opacity';
        obj.GraphicOptions.YDir = 'normal';
        obj.GraphicOptions.Title = 'Opacity';
         if isempty(clims)
            clims = [-0.1 2.5];
        end
        LineoutWidth(obj,xOff,yOff,clims)
        
    case 'Density'
        obj = object.Density;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Density [g/cc]';
        obj.GraphicOptions.Title = 'Abel Inverted Density';
        obj.GraphicOptions.YDir = 'normal';
        if isempty(clims)
            clims = [-0.1 10];
        end
        LineoutWidth(obj,xOff,yOff,clims)
        
end

if nargout>=1
    varargout{1}=gca;
end

end

