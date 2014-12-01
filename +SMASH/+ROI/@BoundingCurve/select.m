% select Interactively select points for a BoundingCurve
%
% This method provides interactive selection of bounding curve points.
% Point selection is controlled with a dialog box and a target axes.
% Clicking on the axes adds the current point to the BoundingCurve object;
% shift-clicking on the axes removes the nearest point and control-clicking
% displays the dialog box.  Bounding points are displayed as a table in the
% dialog box, and edits to this table can be applied to change the point
% locations and local widths.
%
% Standard use of this method is:
%     >> object=select(object,target);
% where "target" is an axes handle.  If no target axes is specified, the
% current axes is used.  The target axes and dialog box are displayed for
% the user, and MATLAB waits until the user presses the "OK" or "Cancel"
% button to resume normal executation.
%
% To implment this method as part of a graphical interface, an apply
% function should be provided.
%     >> dlg=select(object,target,applyFunction); % dlg is a MUI.Dialog object
% Executation is not suspended with this call!  Instead, the function
% handle passed to method is used whenever the "Apply" button is pressed.
% The apply function is also called when the "OK" button is pressed before
% the dialog box is closed.  The apply function is passed a single input:
% the current state of the BoundingCurve object.
%
% See also BoundingCurve, define, insert, remove
%

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=select(object,target,ApplyFunction)

% handle input
if (nargin<2) || isempty(target)
    target=gca;
end
assert(ishandle(target),'ERROR: invalid target axes handle');

if nargin<3
    ApplyFunction=[];
elseif ischar(ApplyFunction)
    ApplyFunction=str2func(ApplyFunction);
else
    assert(isa(ApplyFunction,'function_handle'),...
        'ERROR: invalid Apply function');
end

% create dialog
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Boundary select';
setappdata(dlg.Handle,'PreviousObject',object);

fig=ancestor(target,'figure');
[points,envelope]=view(object,target);
if isempty(object.DefaultWidth)
    switch object.Direction
        case 'horizontal'
            object.DefaultWidth=0.10*diff(ylim(target));
        case 'vertical'
            object.DefaultWidth=0.10*diff(xlim(target));
    end
end
figure(fig);
setappdata(dlg.Handle,'CurrentObject',object);
setappdata(dlg.Handle,'TargetAxes',target);
setappdata(dlg.Handle,'Points',points);
setappdata(dlg.Handle,'Envelope',envelope);
setappdata(dlg.Handle,'TargetFigure',fig);
setappdata(dlg.Handle,'PreviousWindowButtonUpFcn',...
    get(fig,'WindowButtonUpFcn'));
setappdata(dlg.Handle,'PreviousCloseFcn',...
    get(fig,'CloseRequestFcn'));

addblock(dlg,'text','BoundingCurve selection');
label=sprintf('Direction: %s',object.Direction);
addblock(dlg,'text',label);
addblock(dlg,'text',' ');

h=addblock(dlg,'medit','Curve table: [x y width]',45,10);
setappdata(dlg.Handle,'Table',h(end));
makeBold(h(1));
set(h(end),'FontName',get(0,'FixedWidthFontName'));
zoom(fig,'on');zoom(fig,'off'); % reset figure toggle state
set(fig,'WindowButtonUpFcn',{@useMouse,dlg.Handle});
object2table(object,h(end));

h=addblock(dlg,'button',{'Use table','Show plot'});
set(h(1),'Callback',{@useTable,dlg.Handle});
set(h(2),'Callback',{@showPlot,dlg.Handle});
addblock(dlg,'text','Standard click on plot adds a new point');
addblock(dlg,'text','Shift-click on plot removes nearest point');
addblock(dlg,'text','Control-click on plot returns to this dialog');
%addblock(dlg,'text',' ');

h=addblock(dlg,'edit_button',{'Default width:','Set all to default'});
setappdata(dlg.Handle,'DefaultWidth',h(2));
makeBold(h(1));
set(h(2),'HorizontalAlignment','center');
set(h(end),'Callback',{@useWidth,dlg.Handle})
object2width(object,h(2));

h=addblock(dlg,'button',{'Cancel','Cancel','Cancel'});
if isempty(ApplyFunction)
    set(h(1),'String','OK','Callback',{@okCallback1,dlg.Handle});
    set(h(2),'String','Cancel','Callback',{@cancelCallback,dlg.Handle});
    set(h(3),'Visible','off');
else
    set(h(1),'String','OK','Callback',{@okCallback2,dlg.Handle});
    set(h(2),'String','Apply','Callback',{@applyCallback,dlg.Handle});
    set(h(3),'String','Close','Callback',{@closeCallback,dlg.Handle});
end
ok=h(1);
setappdata(dlg.Handle,'okButton',ok);

locate(dlg,'center',fig);
dlg.Hidden=false;
set(dlg.Handle,'HandleVisibility','callback','CloseRequestFcn','');

% manage termination
set(fig,'CloseRequestFcn','');
if isempty(ApplyFunction)
    waitfor(ok);
    varargout{1}=getappdata(dlg.Handle,'CurrentObject');
    try
        set(fig,'WindowButtonUpFcn',...
            getappdata(dlg.Handle,'PreviousWindowButtonUpFcn'));
        set(fig,'CloseRequestFcn',...
            getappdata(dlg.Handle,'PreviousCloseFcn'));
            delete(points);
            delete(envelope);
    catch
        % do nothing
    end
    delete(dlg);
else
    setappdata(dlg.Handle,'ApplyFunction',ApplyFunction);
    varargout{1}=dlg;
end

end

%% callbacks
% "db" is the dialog box handle
function useMouse(~,~,db)

target=getappdata(db,'TargetAxes');
fig=getappdata(db,'TargetFigure');
object=getappdata(db,'CurrentObject');
table=getappdata(db,'Table');
points=getappdata(db,'Points');
envelope=getappdata(db,'Envelope');

current=get(target,'CurrentPoint');
current=current(1,1:2);
switch lower(get(fig,'SelectionType'))
    case 'normal'
        current(3)=object.DefaultWidth;
        object=insert(object,current);
        object2table(object,table);
        object2plots(object,points,envelope);
    case 'extend'
        data=object.Data;
        Lx=diff(xlim(target));
        Ly=diff(ylim(target));
        L2=((data(:,1)-current(1))/Lx).^2+((data(:,2)-current(2))/Ly).^2; % normalized square distance
        [~,index]=min(L2);
        keep=[1:(index-1) (index+1):numel(L2)];
        object.Data=data(keep,:);
        object2table(object,table);
        object2plots(object,points,envelope);
    case 'alt'
        figure(db);
end

setappdata(db,'CurrentObject',object);

end

function useTable(~,~,db)

object=getappdata(db,'CurrentObject');
table=getappdata(db,'Table');
points=getappdata(db,'Points');
envelope=getappdata(db,'Envelope');

entry=get(table,'String');
N=size(entry,1);
data=nan(N,3);
for n=1:N
    try
        [value,count]=sscanf(entry(n,:),'%g',3);
        if count==3
            data(n,:)=transpose(value);
        end
    catch
        % do nothing
    end
end
keep=~isnan(data(:,1));
data=data(keep,:);
object=define(object,data);
object2table(object,table(end));
object2plots(object,points,envelope);

setappdata(db,'CurrentObject',object);

end

function showPlot(~,~,db)

fig=getappdata(db,'TargetFigure');
figure(fig);

end

function useWidth(~,~,db)

object=getappdata(db,'CurrentObject');
table=getappdata(db,'Table');
points=getappdata(db,'Points');
envelope=getappdata(db,'Envelope');
dw=getappdata(db,'DefaultWidth');

[value,count]=sscanf(get(dw,'String'),'%g');
if (count~=1) || (value<0)
    value=object.DefaultWidth;
end
object.DefaultWidth=value;
object2width(object,dw);
object.Data(:,3)=value;
object2table(object,table(end));
object2plots(object,points,envelope);

setappdata(db,'CurrentObject',object);

end

function okCallback1(~,~,db)

ok=getappdata(db,'okButton');
delete(ok);

end

function cancelCallback(~,~,db)

setappdata(db,'CurrentObject',get(db,'PreviousObject'));
ok=getappdata(db,'okButton');
delete(ok);

end

function okCallback2(~,~,db)

applyCallback([],[],db);
closeCallback([],[],db);

end

function applyCallback(~,~,db)

apply=getappdata(db,'ApplyFunction');
object=getappdata(db,'CurrentObject');
feval(apply,object);

end

function closeCallback(~,~,db)

fig=getappdata(db,'TargetFigure');
points=getappdata(db,'Points');
envelope=getappdata(db,'Envelope');
try
    set(fig,'WindowButtonUpFcn',...
        getappdata(db,'PreviousWindowButtonUpFcn'));
    set(fig,'CloseRequestFcn',...
        getappdata(db,'PreviousCloseFcn'));
    delete(points);
    delete(envelope);
catch
    % do nothing
end
delete(db);

end

%% helper functions
function makeBold(target)
set(target,'FontWeight','bold');
extent=get(target,'Extent');
position=get(target,'Position');
position(3)=extent(3);
set(target,'Position',position);

end

function object2table(object,table)

% x/y may be positive or negatie, width is always positive
data=sprintf('%+15.6g %+15.6g %15.6g\n',...
    transpose(object.Data));
switch object.Direction
    case 'horizontal'
        data=sortrows(data,1);
    case 'vertical'
        data=sortrows(data,2);
end
set(table(end),'String',data);

end

function object2plots(object,points,envelope)

x=object.Data(:,1);
y=object.Data(:,2);
width=object.Data(:,3);

set(points,'XData',x,'YData',y);
switch object.Direction
    case 'horizontal'
        y=[y+width; y(end:-1:1)-width(end:-1:1)];
        x=[x;       x(end:-1:1)];
        if numel(x)>0
            x(end+1)=x(1);
            y(end+1)=y(1);
        end
    case 'vertical'
        
end
set(envelope,'XData',x,'YData',y);

end

function object2width(object,dw)

value=sprintf('%13.6g',object.DefaultWidth);
set(dw,'String',strtrim(value));

end