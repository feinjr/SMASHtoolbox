function varargout=view(object,mode,target)

% manage input
if (nargin<2) || isempty(mode)
    mode='original';
end
assert(ischar(mode),'ERROR: invalid view mode');
mode=lower(mode);
assert(strcmp(mode,'original') || strcmp(mode,'final'),...
    'ERROR: invalid view mode');

if (nargin<3) || isempty(target)
    figure;
    NewFigure=true;
    target=axes('Box','on');
    xlabel(object.XLabel);
    ylabel(object.YLabel);    
else
    assert(ishandle(target) && strcmpi(get(target,'Type'),'axes'),...
        'ERROR: invalid target axes');
    NewFigure=false;
end

% plot original boundary curve
switch mode
    case 'original'
        h{1}=line('Parent',target,...
            'XData',object.Original.Boundary(:,1),...
            'YData',object.Original.Boundary(:,2),...
            'Color','k','LineWidth',0.5);
        h{2}=line('Parent',target,...
            'XData',object.Original.Mode(1),...
            'YData',object.Original.Mode(2),...
            'Color','k','Marker','+');
    case 'final'
        h{1}=view(object.Final.Image,'show',target);        
        h{2}=line('Parent',target,...
            'XData',object.Final.Boundary(:,1),...
            'YData',object.Final.Boundary(:,2),...
            'Color','k','LineWidth',0.5);
        h{3}=line('Parent',target,...
            'XData',object.Final.Mode(1),...
            'YData',object.Final.Mode(2),...
            'Color','k','Marker','+');
end
if NewFigure
    axis(target,'auto');
end

% manage output
if nargout>0
    varargout{1}=h;
end

end