% ALIGN Align Streak objects
%
% This method aligns a Streak object to an event specified by a path
% of (x,y) points.
%
% Usage:
%   >> object=align(object,xypath,order);
%   -xypath should be table of [x y] values 
%   -order is the polynomial order used to define the alignment boundary
%   (default is 1).
% Users will be prompted to select the xypath if input table is omitted.
%
% See also ImageAnalysis, STREAK

% created 7/27/2012 by Daniel Dolan (Sandia National Laboratories)
% modified January 2, 2014 by Tommy Ao (Sandia National Laboratories)
% 
function [object,xypath]=align(object,xypath,order)

% handle input
if (nargin<2) || isempty(xypath) % display image so user can select (x,y) points
    xypath=SelectPoints(object.StreakDirection,object);
end
x=xypath(:,1);
y=xypath(:,2);

if (nargin<3) || isempty(order)
    order=1;
end

switch lower(object.StreakDirection)
    case 'grid1'
        param=polyfit(y,x,order);
        xmid=(max(x)+min(x))/2;
        for k=1:numel(object.Grid2)
            xk=polyval(param,object.Grid2(k));
            shift=xk-xmid;
            object.Data(k,:)=...
                interp1(object.Grid1-shift,object.Data(k,:),object.Grid1,...
                'linear',0);
        end
    case 'grid2'
        param=polyfit(x,y,order);
        ymid=(max(y)+min(y))/2;
        for k=1:numel(object.Grid1)
            yk=polyval(param,object.Grid1(k));
            shift=yk-ymid;
            object.Data(:,k)=...
                interp1(object.Grid2-shift,object.Data(:,k),object.Grid2,...
                'linear',0);
        end
end

object=updateHistory(object);

end

function xypath=SelectPoints(direction,object)

% have user zoom into alignment path
h=view(object,'show');
title(h.axes,'Zoom into the alignment feature');
hzoom=zoom(h.figure);
set(hzoom,'Enable','on');
switch direction
    case 'vertical'
        set(hzoom,'Motion','vertical');
    case 'horizontal'
        set(hzoom,'Motion','horiztonal');
end
hc=uicontrol('Parent',h.panel,'Style','pushbutton','String',' Next ',...
    'Callback','delete(gcbo)');
waitfor(hc);
set(hzoom,'Enable','off');

% select alignment points
set(h.image,'ButtonDownFcn',@CreatePoint)
hc=uicontextmenu;
uimenu(hc,'Label','Remove point','Callback',@RemovePoint);
hl=line('Parent',h.axes,'UIContextMenu',hc,...
    'XData',[],'YData',[],'LineStyle','none',...
    'MarkerEdgeColor',object.LineColor,...
    'MarkerFaceColor',object.LineColor,...
    'Marker',object.Marker,'MarkerSize',object.MarkerSize);
title('Select alignment points');
    function CreatePoint(varargin)
        x=get(hl,'XData');
        y=get(hl,'YData');
        current=get(h.axes,'CurrentPoint');
        x(end+1)=current(1,1);
        y(end+1)=current(1,2);
        set(hl,'XData',x,'YData',y);
    end
    function RemovePoint(varargin)
        x=get(hl,'XData');
        y=get(hl,'YData');
        current=get(h.axes,'CurrentPoint');
        x0=current(1,1);
        y0=current(1,2);
        d2=(x-x0).^2+(y-y0).^2;
        [~,index]=min(d2);
        x(index)=[];
        y(index)=[];
        set(hl,'XData',x,'YData',y);
    end

hc=uicontrol('Style','pushbutton','String',' Done ',...
    'Callback','delete(gcbo)');
waitfor(hc);

xypath=[x(:) y(:)];
delete(h.figure);

end