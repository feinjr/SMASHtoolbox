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

if Narg == 0
    view(object.Measurement)
elseif Narg == 1
    option = varargin{1};
elseif Narg == 2
    option = varargin{1};
    clims = varargin{2};
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
        view(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% View each of the cropped TIPC images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
    case 'Images'
        obj = object.Images;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Transmission';
        obj.GraphicOptions.YDir = 'normal';
        if isempty(clims)
            clims = [-100 6000];
        end
        filters = object.Settings.Filters;
        filter_label = cell(object.Settings.NumberImages,1);
        channel = object.Images.Legend;
        
        for i = 1:object.Settings.NumberImages
            if size(filters.Thickness,2) == 2
                [~,thickness] = filters.Thickness.(channel{i});
                [~,material] = filters.Material.(channel{i});
            elseif size(filters.Thickness,2) == 1
                thickness = filters.Thickness.(channel{i});
                material = filters.Material.(channel{i});
            end
            filter_label{i} = [num2str(thickness), ' \mum ', material];
        end
        
        figure('Units','Inches','Position',[7,6,10,6],'Color','w','PaperPositionMode','auto')
        for i = 1:object.Settings.NumberImages
            subplot('Position',[0.075+(i-1)*0.18,0.11, 0.15,0.82])
            ax(i) = gca;
            set(ax(i),'XScale','lin','YScale','lin',...
                'FontSize',10,'box','on','FontWeight','normal','TickDir','out','FontName','Times','YDir','normal')
            hold on
            imagesc(obj.Grid1,obj.Grid2,obj.Data(:,:,i))
            axis equal
            thl = title(filter_label{i});
            thl.FontSize = 12;
            xlabel('Radial Position [cm]')
            xmid  = (obj.Grid1(end) - obj.Grid1(1))/2;
            
            text(obj.Grid1(1)+xmid*0.8,obj.Grid2(end)*0.85,obj.Legend{i},'FontSize',20,'Color','w','FontWeight','bold')
            if i == 1
                ylabel('Height [cm]')
            end
            if i ~= 1
                ax(i).YTickLabel = '';
            end
            set(gca,'CLim',clims)
            xlim([obj.Grid1(1), obj.Grid1(end)])
            ylim([obj.Grid2(1), obj.Grid2(end)])
        end
        linkaxes(ax)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% View each of the cropped, background corrected and registered TIPC images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
    case 'Registered'
        obj = object.RegisteredImages;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Transmission';
        obj.GraphicOptions.YDir = 'normal';
        if isempty(clims)
            clims = [-100 6000];
        end
        filters = object.Settings.Filters;
        filter_label = cell(object.Settings.NumberImages,1);
        channel = object.Images.Legend;
        
        for i = 1:object.Settings.NumberImages
            if size(filters.Thickness,2) == 2
                [~,thickness] = filters.Thickness.(channel{i});
                [~,material] = filters.Material.(channel{i});
            elseif size(filters.Thickness,2) == 1
                thickness = filters.Thickness.(channel{i});
                material = filters.Material.(channel{i});
            end
            filter_label{i} = [num2str(thickness), ' \mum ', material];
        end
        
        figure('Units','Inches','Position',[7,6,10,6],'Color','w','PaperPositionMode','auto')
        for i = 1:object.Settings.NumberImages
            subplot('Position',[0.075+(i-1)*0.18,0.11, 0.15,0.82])
            ax(i) = gca;
            set(ax(i),'XScale','lin','YScale','lin',...
                'FontSize',10,'box','on','FontWeight','normal','TickDir','out','FontName','Times','YDir','normal')
            hold on
            imagesc(obj.Grid1,obj.Grid2,obj.Data(:,:,i))
            axis equal
            thl = title(filter_label{i});
            thl.FontSize = 12;
            xlabel('Radial Position [cm]')
            xmid  = (obj.Grid1(end) - obj.Grid1(1))/2;
            
            text(obj.Grid1(1)+xmid*0.8,obj.Grid2(end)*0.85,obj.Legend{i},'FontSize',20,'Color','w','FontWeight','bold')
            if i == 1
                ylabel('Height [cm]')
            end
            if i ~= 1
                ax(i).YTickLabel = '';
            end
            set(gca,'CLim',clims)
            xlim([obj.Grid1(1), obj.Grid1(end)])
            ylim([obj.Grid2(1), obj.Grid2(end)])
        end
        linkaxes(ax)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% View each of the cropped, background corrected and registered TIPC images
% and a bar chart showing the integrated intensity of each bin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
              
    case 'Summary'
        obj = object.RegisteredImages;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Transmission';
        obj.GraphicOptions.YDir = 'normal';
        if isempty(clims)
            clims = [-100 6000];
        end
        filters = object.Settings.Filters;
        filter_label = cell(object.Settings.NumberImages,1);
        channel = object.Images.Legend;
        
        for i = 1:object.Settings.NumberImages
            if size(filters.Thickness,2) == 2
                [~,thickness] = filters.Thickness.(channel{i});
                [~,material] = filters.Material.(channel{i});
            elseif size(filters.Thickness,2) == 1
                thickness = filters.Thickness.(channel{i});
                material = filters.Material.(channel{i});
            end
            filter_label{i} = [num2str(thickness), ' \mum ', material];
        end
        
        figure('Units','Inches','Position',[7,6,10,6],'Color','w','PaperPositionMode','auto')
        for i = 1:object.Settings.NumberImages
            subplot('Position',[0.075+(i-1)*0.12,0.11, 0.1,0.82])
            ax(i) = gca;
            set(ax(i),'XScale','lin','YScale','lin',...
                'FontSize',10,'box','on','FontWeight','normal','TickDir','out','FontName','Times','YDir','normal')
            hold on
            imagesc(obj.Grid1,obj.Grid2,obj.Data(:,:,i))
%             axis equal
            thl = title(filter_label{i});
            thl.FontSize = 12;
            
            xmid  = (obj.Grid1(end) - obj.Grid1(1))/2;
            
            text(obj.Grid1(1)+xmid*0.8,obj.Grid2(end)*0.85,obj.Legend{i},'FontSize',20,'Color','w','FontWeight','bold')
            if i == 1
                ylabel('Height [cm]')
                xlh = xlabel('Radial Position [cm]');
                xlh.Position = [1 -0.6692 -1];
            end
            if i ~= 1
                ax(i).YTickLabel = '';
            end
            set(gca,'CLim',clims)
            xlim([obj.Grid1(1), obj.Grid1(end)])
            ylim([obj.Grid2(1), obj.Grid2(end)])
        end
        linkaxes(ax)
        
        subplot('Position',[0.71,0.11,0.24,0.82])
        hold all;
        barh(object.Summary.Yvalues, object.Summary.Intensity,'stacked')
        ax2 = gca;
        legend(filter_label,'Location','SouthEast')
        ylim([obj.Grid2(1), obj.Grid2(end)])
        % xlim([-0.1 0.5])
        xlabel('Intensity [A.U.]')
        ylabel('Height [mm]')
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% view a bar chart showing the intensity of each slice of each image, as
% well as the uncertainties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
              
    case 'Bins'
        
end
varargout{1} = gcf;
end

