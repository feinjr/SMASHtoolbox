function [ varargout ] = viewproperties( object, varargin )
%% [ varargout ] = viewproperties( object, varargin )
%
% This method allows the user to view specialized plots of various aspects
% of the TIPC object.  Passing various keywords selects different aspects
% of the data to summarize graphically.
%
%   keywords:
%       'Data': View the full, raw TIPC image
%       'Images': View each of the cropped TIPC images
%       'Registered': View each of the cropped, background corrected and
%           registered TIPC images
%       'Fuse': View each of the registered images "fused" with the
%           refernce image.  This view is good for determining how well
%           registered the images are.
%       'Summary': View each of the cropped, background corrected and
%           registered TIPC images and a bar chart showing the integrated
%           intensity of each bin
%       'Bins': view a bar chart showing the intensity of each slice of
%           each image, as well as the uncertainties
%
%   output: optional output returns the figure handle
%
% See also TIPC, Xray, Image, Radiography
% created March 1, 2017 by Patrick Knapp (Sandia National Laboratories)
%
%%
Narg=numel(varargin);
clims = [];
Levels = [];
AspectRatio_in = [];
xlims = [-0.05, 0.05];
ylims = [-0.45, 0.45];
DataScale = 'lin';

if Narg == 0
    view(object.Measurement)
elseif Narg == 1
    option = varargin{1};
elseif Narg == 2
    option = varargin{1};
    clims = varargin{2};
elseif Narg > 2
    option = varargin{1};
    clims = varargin{2};
    for i = 1:length(varargin)
        if strcmp(varargin{i},'Levels'); Levels = varargin{i+1};
        elseif strcmp(varargin{i},'AspectRatio'); AspectRatio_in = varargin{i+1};
        elseif strcmp(varargin{i},'XLims'); xlims = varargin{i+1};
        elseif strcmp(varargin{i},'YLims'); ylims = varargin{i+1};
        elseif strcmp(varargin{i},'DataScale'); DataScale = varargin{i+1};
        end
    end
end

switch option
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % View the full, raw TIPC image
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'Data'
        obj = object.Measurement;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Raw Image';
        obj.GraphicOptions.YDir = 'normal';
        
        if isempty(AspectRatio_in)
           obj.GraphicOptions.AspectRatio = 'auto'; 
        else
           obj.GraphicOptions.AspectRatio = AspectRatio_in; 
        end
        view(obj)
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % View the cropped image w/ contours overlayed
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'Image'
        obj = object.Image;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Exposure';
        obj.GraphicOptions.YDir = 'normal';
        obj.GraphicOptions.AspectRatio = 'equal';
        
        if isempty(AspectRatio_in)
            AspectRatio = object.Image.GraphicOptions.AspectRatio;
        else
            AspectRatio = AspectRatio_in;
        end
        
        if isempty(clims)
            clims = [-100 8000];
        end
        
        figure('Units','Inches','Position',[7,6,3,8],'Color','w','PaperPositionMode','auto')
        hold on
        
        colormap('hot')
        imagesc(obj.Grid1, obj.Grid2, obj.Data, clims)
        axis(AspectRatio)
        
        set(gca,'YDir',obj.GraphicOptions.YDir)
        xlabel(obj.Grid1Label);
        ylabel(obj.Grid2Label);
        title(obj.DataLabel);
        colorbar
        ylim(ylims)
        xlim(xlims)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % View the cropped image w/ contours overlayed
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case 'Contour'
        obj = object.Image;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Exposure';
        obj.GraphicOptions.YDir = 'normal';
        obj.GraphicOptions.AspectRatio = 'equal';
        
        obj_smooth = smooth(obj,'mean',[4,4]);
        
        if isempty(clims)
            clims = [-100 10000];
        end
        if isempty(Levels)
            Levels = [0.05, 0.1, 0.2, 0.4];
        end
        
        if isempty(AspectRatio_in)
            AspectRatio = object.Image.GraphicOptions.AspectRatio;
        else
            AspectRatio = AspectRatio_in;
        end
        
        figure('Units','Inches','Position',[7,6,3,8],'Color','w','PaperPositionMode','auto')
        hold on
        
        colormap('hot')
        imagesc(obj.Grid1, obj.Grid2, obj.Data, clims)
        axis(AspectRatio)
        
        contour(obj.Grid1, obj.Grid2, obj_smooth.Data/max(obj_smooth.Data(:)),Levels,'Color','w')
        
        set(gca,'YDir',obj.GraphicOptions.YDir)
        xlabel(obj.Grid1Label);
        ylabel(obj.Grid2Label);
        title(obj.DataLabel);
        colorbar
        ylim(ylims)
        xlim(xlims)
       
        
    case 'Summary'
        
    case 'Width'
        obj = object.Image;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Exposure';
        obj.GraphicOptions.YDir = 'normal';
        obj.GraphicOptions.AspectRatio = 'equal';
        
        p = object.Summary;
        
        if isempty(clims)
            clims = [-100 10000];
        end
        
        if isempty(AspectRatio_in)
            AspectRatio = object.Image.GraphicOptions.AspectRatio;
        else
            AspectRatio = AspectRatio_in;
        end
        
        figure('Units','Inches','Position',[7,6,3,8],'Color','w','PaperPositionMode','auto')
        hold on
        
        colormap('hot')
        if strcmp(DataScale,'lin')
            imagesc(obj.Grid1, obj.Grid2, obj.Data, clims)
        elseif strcmp('DataScale','log')
            data = obj.Data;
            data(data < 1) = 1;
            imagesc(obj.Grid1, obj.Grid2, log10(data))
        end
        
        axis(AspectRatio)
        
        plot(p.Center,p.Height,'g')
        plot(p.Center+p.RightSide,p.Height,'w')
        plot(p.Center-p.LeftSide,p.Height,'w')
        
        plot(p.Center+p.Width/2,p.Height,'--w')
        plot(p.Center-p.Width/2,p.Height,'--w')
        
        set(gca,'YDir',obj.GraphicOptions.YDir)
        xlabel(obj.Grid1Label);
        ylabel(obj.Grid2Label);
        title(obj.DataLabel);
        colorbar
        ylim(ylims)
        xlim(xlims)
end

varargout{1} = gcf;
end

