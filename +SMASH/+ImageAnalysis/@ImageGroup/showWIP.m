% SHOW Standard view showing Image objects
%
% See also Image, detail, explore, slice, view

% created October 15, 2013 by Tommy Ao (Sandia National Laboratories)
%
function varargout=showWIP(object,target)

% handle input
if (nargin<2) || isempty(target)
    h=basic_figure;
    h.axes1=axes('Parent',h.panel,'Box','on','Position',[0.1 0.1 0.4 0.4]);
    h.axes2=axes('Parent',h.panel,'Box','on','Position',[0.5 0.5 0.4 0.4]);
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

h.image1=imagesc('Parent',h.axes1,...
    'XData',x,'YData',y,'CData',z(:,:,1));
apply(object.GraphicOptions,h.axes1);
axis(h.axes1,'tight');

colormap(h.axes1,object.GraphicOptions.ColorMap);
xlabel(h.axes1,object.Grid1Label);
ylabel(h.axes1,object.Grid2Label);
title(h.axes1,object.GraphicOptions.Title);

cb=SMASH.MUI.Colorbar;
ylabel(cb.Handle,object.DataLabel);

h.image2=imagesc('Parent',h.axes2,...
    'XData',x,'YData',y,'CData',z(:,:,2));
apply(object.GraphicOptions,h.axes2);
axis(h.axes2,'tight');

colormap(h.axes2,object.GraphicOptions.ColorMap);
xlabel(h.axes2,object.Grid1Label);
ylabel(h.axes2,object.Grid2Label);
title(h.axes2,object.GraphicOptions.Title);

ylabel(cb.Handle,object.DataLabel);

if ~isempty(object.DataLim)
    caxis(h.axes1,object.DataLim);
end

figure(h.figure);

% handle output
if nargout>=1
    varargout{1}=h;
end
    
    
end