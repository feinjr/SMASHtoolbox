% interactively manage MultiBound objects
%
%

function varargout=manage(object,target,varargin)

% handle input
if (nargin<2) || isempty(target)
    target=gca;
end
assert(ishandle(target),'ERROR: invalid target axes');


% advanced option management
ApplyFunction=[];

% create dialog
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='MultipleBound manager';

setappdata(dlg.Handle,'PreviousObject',object);
setappdata(dlg.Handle,'CurrentObject',object);
setappdata(dlg.Handle,'TargetAxes',target);

addblock(dlg,'text','MultipleBound manager');

h=addblock(dlg,'edit','Label:',20);
setappdata(dlg.Handle,'Label',h(2));
makeBold(h(1));
set(h(end),'String',object.Label,'Callback',{@changeLabel,dlg.Handle});

h=addblock(dlg,'popup','Current bound:',{'1'},20);
makeBold(h(1));
setappdata(dlg.Handle,'PopupMenu',h(2));
updatePopup(dlg.Handle);

addblock(dlg,'button',{'Edit','Promote','Demote'});
%addblock(dlg,'button',{'Promote','Demote'});
addblock(dlg,'button',{'Add new','Remove current'});

h=addblock(dlg,'button',{'Cancel','Cancel','Cancel'});
if isempty(ApplyFunction)
    set(h(1),'String','OK','Callback',{@okCallback1,dlg.Handle});
    set(h(2),'String','Cancel','Callback',{@cancelCallback,dlg.Handle});
    set(h(3),'Visible','off');
else
    %set(h(1),'String','OK','Callback',{@okCallback2,dlg.Handle});
    %set(h(2),'String','Apply','Callback',{@applyCallback,dlg.Handle});
    %set(h(3),'String','Close','Callback',{@closeCallback,dlg.Handle});
end

dlg.Hidden=false;
set(dlg.Handle,'HandleVisibility','callback');%,'CloseRequestFcn','
end

%% callbacks
% "db" is the dialog box handle
function changeLabel(~,~,db)

object=getappdata(db,'CurrentObject');
l=getappdata(db,'Label');
object.Label=get(l,'String');
setappdata(db,'CurrentObject',object);

end

%% helper functions
function makeBold(target)
set(target,'FontWeight','bold');
extent=get(target,'Extent');
position=get(target,'Position');
position(3)=extent(3);
set(target,'Position',position);

end

function updatePopup(db)

object=getappdata(db,'CurrentObject');
popup=getappdata(db,'PopupMenu');

N=numel(object.BoundArray);
if N==0
    set(popup,'String','(none)','Enable','off');
else
    choice=cell(1,N);
    for n=1:N
        choice{n}=object.BoundArray{n}.Label;
    end
    set(popup,'String',choice,'Enable','on');
end


end