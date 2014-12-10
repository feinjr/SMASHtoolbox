% apply Apply PlotOptions to existing graphic(s)
%
% This method applies settings from a PlotOptions object to an existing
% graphic object.
%     >> apply(object,target); 
% The input "target" must be a graphic handle or an array of handles.
% Settings are applied to the target and all its parent objects (axes,
% figure, etc.).
%
% See also PlotOptions
%

%
% created November 17, 2014 by Daniel Dolan (Sandia National Laboratory)
%
function apply(object,target)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs');
if numel(target)>1
    for k=1:numel(target)
        apply(object,target(k));
    end
    return
end

assert(ishandle(target),'ERROR: invalid target handle');

switch get(target,'Type')
    case 'line'
        set(target,'Color',object.LineColor);
        set(target,'LineStyle',object.LineStyle);
        set(target,'LineWidth',object.LineWidth);
        set(target,'Marker',object.Marker);
        set(target,'MarkerSize',object.MarkerSize);
        set(target,'MarkerEdgeColor',object.LineColor);
        switch object.MarkerStyle
            case 'open'
                set(target,'MarkerFaceColor','none');
            case 'closed'
                set(target,'MarkerFaceColor',object.LineColor);
        end
        parent=get(target,'Parent');
        apply(object,parent);
    case 'image'
        parent=get(target,'Parent');
        apply(object,parent);
    case 'axes'
        switch object.AspectRatio
            case 'auto'
                daspect(target,'auto');
                pbaspect(target,'auto');
            case 'equal'
                daspect(target,[1 1 1]);
                pbaspect(target,[1 1 1]);
        end
        set(target,'Color',object.AxesColor);
        set(target,'Box',object.Box);
        set(target,'XDir',object.XDir);
        set(target,'YDir',object.YDir);
        title(target,object.Title);
        parent=get(target,'Parent');
        apply(object,parent);
    case 'uipanel'
        set(target,'BackgroundColor',object.PanelColor);
        parent=get(target,'Parent');
        apply(object,parent);
    case 'figure'
        set(target,'ColorMap',object.ColorMap);
        set(target,'Color',object.FigureColor);
end


end