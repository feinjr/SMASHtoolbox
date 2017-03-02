function varargout = viewproperties( object,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Narg=numel(varargin);
clims = [];

if Narg == 0
    view(object.Measurement)
elseif Narg == 1
    option = varargin{1};
elseif Narg == 2
    option = varargin{1};
    clims = varargin{2};
end
switch option
    case 'Data'
        obj = object.Measurement;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Raw Radiograph';
        obj.GraphicOptions.YDir = 'normal';
        view(obj)
        
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
        view(obj)
        set(gca,'CLim',clims)
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
        view(obj)
        set(gca,'CLim',clims)
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
        view(obj)
        set(gca,'CLim',clims)
        
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
        view(obj)
        set(gca,'CLim',clims)        
        
end

if nargout>=1
    varargout{1}=gca;
end

end

