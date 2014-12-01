% SHOW Standard view showing Image objects
%
% See also Image, detail, explore, slice, view

% created October 15, 2013 by Tommy Ao (Sandia National Laboratories)
%
function varargout=show(object,target)

% handle input
if (nargin<2) || isempty(target) % || isnan(target) % change needed for 2014B
    h=basic_figure;
    h.axes=axes('Parent',h.panel,'Box','on');
else
    h.figure=ancestor(target,'figure');
    h.axes=target;
    cla(h.axes);
end

% display image
[x,y,z]=limit(object);
switch object.DataScale
    case 'log'
        z=log10(z);
        object.DataLabel=sprintf('%s (log scale)',object.DataLabel);
    case 'dB'
        z=10*log10(z);
        object.DataLabel=sprintf('%s (dB)',object.DataLabel);
end

h.image=imagesc('Parent',h.axes,...
    'XData',x,'YData',y,'CData',z);
axis(h.axes,'tight');
if isempty(object.ColorMap)
    object.ColorMap=colormap;
end
colormap(h.axes,double(object.ColorMap));
xlabel(h.axes,object.Grid1Label);
ylabel(h.axes,object.Grid2Label);
title(h.axes,object.Title);
switch object.AspectRatio
    case 'auto'
        daspect(h.axes,'auto');
        pbaspect(h.axes,'auto');
    case 'equal'
        daspect(h.axes,[1 1 1]);
        pbaspect(h.axes,[1 1 1]);
end

%hc=basic_colorbar;
%setappdata(hc,'TargetAxes',h.axes);
%ylabel(hc,object.DataLabel);
cb=SMASH.MUI.Colorbar;
ylabel(cb.Handle,object.DataLabel);

set(h.axes,'YDir',object.YDir);

if ~isempty(object.DataLim)
    caxis(h.axes,object.DataLim);
end

figure(h.figure);

% handle output
if nargout>=1
    varargout{1}=h;
end
    
    
end