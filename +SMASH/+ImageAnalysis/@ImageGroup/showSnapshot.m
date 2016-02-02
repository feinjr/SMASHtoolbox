% SHOWSNAPSHOT View showing ImageGroup objects with one Image brought to prominance
%
% This view method brings up one of the Image objects within the ImageGroup
% to the primary plot, while the others are contained in a smaller slide
% of thumbnails.
% 
% Selecting one of the Images from the thumbnails will bring that Image
% up to the main plot.
% 
% If called with an output, the graphics handle is given:
%   handle = view(object,'detail');
% Otherwise, the object is just plotted.
% 
% See also ImageGroup, showMosaic, showSingle, slice, view

% created February 2, 2016 by Sean Grant (Sandia National Laboratories/UT)
%
function varargout=showSnapshot(object,target)

NImages=object.NumberImages;

% handle input
if (nargin<2) || isempty(target)
    h=basic_figure;
    h.axes=axes('Parent',h.panel,'Box','on','Position',[0.1 0.4 0.8 0.5]);
else
    h.figure=ancestor(target,'figure');
    h.axes=target;
    set(h.axes,'Position',[0.1 0.4 0.8 0.5]);
    cla(h.axes);
end

% create scrollable panel for mini-view
h.panel = uipanel(h.figure,'Title','Frame Selection',...
             'Position',[0 .1 NImages*.2+.4 .2]);
h.slider=uicontrol(h.figure,'Style','slider','Min',0,'Max',NImages*.2-.6,...
    'Units','normalized','Position',[.1 .05 .8 .03]);
set(h.slider,'Callback', @(hObject,eventdata) set(h.panel,...
    'Position',[-get(hObject,'Value') .1 NImages*.2+.4 .2]));


% handle image data
[x,y,z]=limit(object);
switch object.DataScale
    case 'log'
        z=log10(z);
        object.DataLabel=sprintf('%s (log scale)',object.DataLabel);
    case 'dB'
        z=10*log10(z);
        object.DataLabel=sprintf('%s (dB)',object.DataLabel);
end

% plot main image (initial default to first Image)
h.image1=imagesc('Parent',h.axes,...
    'XData',x,'YData',y,'CData',z(:,:,1));
apply(object.GraphicOptions,h.axes);
axis(h.axes,'tight');

colormap(h.axes,object.GraphicOptions.ColorMap);
xlabel(h.axes,object.Grid1Label);
ylabel(h.axes,object.Grid2Label);
title(h.axes,object.GraphicOptions.Title);

cb=SMASH.MUI.Colorbar;
ylabel(cb.Handle,object.DataLabel);

% create axes within the scroll panel
h.panAx=axes('Parent',h.panel);
sub=cell(NImages,1);
img=cell(NImages,1);
for n=1:NImages
    % create subplots within scroll panel
    sub{n}=subplot(1,NImages,n);
    
    % plot each image within a given supblot
    img{n}=imagesc('Parent',sub{n},...
        'XData',x,'YData',y,'CData',z(:,:,n));
    apply(object.GraphicOptions,sub{n});
    axis(sub{n},'tight');

    colormap(sub{n},object.GraphicOptions.ColorMap);
    xlabel(sub{n},object.Grid1Label);
    ylabel(sub{n},object.Grid2Label);
    title(sub{n},[object.Legend{n},'(',num2str(n),')']);

    cb=SMASH.MUI.Colorbar;
    ylabel(cb.Handle,object.DataLabel);

    % clicking an images brings it to the main plot
    set(sub{n},'ButtonDownFcn',{@plotMain,n});
    set(img{n},'ButtonDownFcn',{@plotMain,n});
end


if ~isempty(object.DataLim)
    caxis(h.axes,object.DataLim);
end

figure(h.figure);

% handle output
if nargout>=1
    varargout{1}=h;
end
    
    function plotMain(hObject,eventdata,n)
        cla(h.axes);
        h.image1=imagesc('Parent',h.axes,...
            'XData',x,'YData',y,'CData',z(:,:,n));
        apply(object.GraphicOptions,h.axes);
        axis(h.axes,'tight');

        colormap(h.axes,object.GraphicOptions.ColorMap);
        xlabel(h.axes,object.Grid1Label);
        ylabel(h.axes,object.Grid2Label);
        title(h.axes,object.GraphicOptions.Title);

        cb=SMASH.MUI.Colorbar;
        ylabel(cb.Handle,object.DataLabel);
    end
    
end