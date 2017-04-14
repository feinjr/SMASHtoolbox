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
AspectRatio_in = [];
xlims = [-0.2, 0.2];
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
        if isempty(clims)
            clims = [-100 6000];
        end
        obj = object.Measurement;
        obj.DataLim = clims;
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
        if isempty(AspectRatio_in)
            obj.GraphicOptions.AspectRatio = 'auto';
        else
            obj.GraphicOptions.AspectRatio = AspectRatio_in;
        end
        
        if isempty(xlims); xlims = [obj.Grid1(1), obj.Grid1(end)]; end
        if isempty(ylims); ylims = [obj.Grid2(1), obj.Grid2(end)]; end
        
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
            xlim(xlims)
            ylim(ylims)
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
        if isempty(xlims); xlims = [obj.Grid1(1), obj.Grid1(end)]; end
        if isempty(ylims); ylims = [obj.Grid2(1), obj.Grid2(end)]; end
        if isempty(AspectRatio_in)
            obj.GraphicOptions.AspectRatio = 'auto';
        else
            obj.GraphicOptions.AspectRatio = AspectRatio_in;
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
            xlim(xlims)
            ylim(ylims)
        end
        linkaxes(ax)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % View the registered images fused with the reference image
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'Fuse'
        obj = object.RegisteredImages;
        obj.Grid1Label = 'Radial Distance [mm]';
        obj.Grid2Label = 'Axial Distance [mm]';
        obj.DataLabel = 'Exposure';
        obj.GraphicOptions.Title = 'Transmission';
        obj.GraphicOptions.YDir = 'normal';
        if isempty(clims)
            clims = [-100 6000];
        end
        if isempty(xlims); xlims = [obj.Grid1(1), obj.Grid1(end)]; end
        if isempty(ylims); ylims = [obj.Grid2(1), obj.Grid2(end)]; end
        if isempty(AspectRatio_in)
            obj.GraphicOptions.AspectRatio = 'auto';
        else
            obj.GraphicOptions.AspectRatio = AspectRatio_in;
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
        
        ref = obj.Data(:,:,object.Settings.ReferenceImage);
        figure('Units','Inches','Position',[7,6,10,6],'Color','w','PaperPositionMode','auto')
        for i = 1:object.Settings.NumberImages
            subplot('Position',[0.075+(i-1)*0.18,0.11, 0.15,0.82])
            ax(i) = gca;
            set(ax(i),'XScale','lin','YScale','lin',...
                'FontSize',10,'box','on','FontWeight','normal','TickDir','out','FontName','Times','YDir','normal')
            hold on
            if i == object.Settings.ReferenceImage
                reg = obj.Data(:,:,i);
                im_fused = fuse(ref,reg);
                
                imagesc(obj.Grid1,obj.Grid2,im_fused)
                axis equal
                
            elseif i ~= object.Settings.ReferenceImage
                
                reg = obj.Data(:,:,i);
                im_fused = fuse(ref,reg);
                imagesc(obj.Grid1,obj.Grid2,im_fused)
                axis equal
                
            end
            thl = title([channel{i},'/',channel{object.Settings.ReferenceImage}]);
            thl.FontSize = 12;
            if i == 1
                ylabel('Height [cm]')
                xlh = xlabel('Radial Position [cm]');
                xlh.Position = [1 -0.6692 -1];
            end
            if i ~= 1
                ax(i).YTickLabel = '';
            end
            xlim(xlims)
            ylim(xlims)
            
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
        if isempty(xlims); xlims = [obj.Grid1(1), obj.Grid1(end)]; end
        if isempty(ylims); ylims = [obj.Grid2(1), obj.Grid2(end)]; end

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
            xlim(xlims)
            ylim(ylims)
        end
        linkaxes(ax)
        
        subplot('Position',[0.69,0.11,0.26,0.82])
        ax2 = gca;
        set(ax2,'XScale','lin','YScale','lin',...
            'FontSize',10,'box','on','FontWeight','normal','TickDir','out','FontName','Times','YDir','normal')
        hold all;
        barh(object.Summary.Yvalues, object.Summary.Intensity,'stacked')
        legend(filter_label,'Location','Best')
        ax2.YTickLabel = '';
        ylim(ylims)
        xlabel('Intensity [A.U.]')
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % view a bar chart showing the intensity of each slice of each image, as
        % well as the uncertainties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'Bins'
        data = object.Summary;
        
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
        
        xmid = zeros(object.Settings.NumberImages,1);
        bh = zeros(object.Settings.NumberImages,1);
        figure('Units','Inches','Position',[7,6,10,6],'Color','w','PaperPositionMode','auto')
        hold all
        ax1 = gca;
        set(ax1,'XScale','lin','YScale','lin',...
            'FontSize',16,'box','on','FontWeight','normal','TickDir','out','FontName','Times','YDir','normal')
        colors = lines(object.Settings.NumberImages);
        for i = 1:object.Settings.NumberImages
            x = (1:object.Settings.Nslices) + 1.25*(i-1)*object.Settings.Nslices;
            bh(i) = bar(x,data.Intensity(:,i),'FaceColor',colors(i,:));
            errorbar(x,data.Intensity(:,i),1*data.Uncertainty(:,i),'linestyle','none','color','k')
            xmid(i) = mean(x);
        end
        ax1.XTick = xmid;
        ax1.XTickLabel = channel;
        xlim([min(xmid)-15 max(xmid)+15])
        ylim([-0.25, 1.25*max(data.Intensity(:))])
        legend(bh, filter_label,'Location','Best');
        ylabel('Intensity')
end
varargout{1} = gcf;
end

