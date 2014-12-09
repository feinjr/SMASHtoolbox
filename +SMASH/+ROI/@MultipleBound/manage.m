% interactively manage MultiBound objects
%
%

function varargout=manage(object,target,varargin)

% handle input
if (nargin<2) || isempty(target)
    target=[];
end

% advanced option management
ApplyFunction=[];

% create dialog
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='MultipleBound manager';
set(dlg.Handle,'NextPlot','new');

setappdata(dlg.Handle,'PreviousObject',object);
setappdata(dlg.Handle,'CurrentObject',object);
setappdata(dlg.Handle,'TargetAxes',target);

addblock(dlg,'text','MultipleBound manager');

h=addblock(dlg,'edit','Label:',20);
setappdata(dlg.Handle,'Label',h(2));
makeBold(h(1));
set(h(end),'String',object.Label,'Callback',{@changeLabel,dlg.Handle});

h=addblock(dlg,'button',{'Add new bound'});
set(h(1),'Callback',{@addCallback,dlg.Handle})

h=addblock(dlg,'popup','Current bound:',{'1'},20);
makeBold(h(1));
popup=h(2);
setappdata(dlg.Handle,'PopupMenu',popup);
updatePopup(dlg.Handle);

h=addblock(dlg,'button',{'Select','Promote','Demote','Remove'});
set(h(1),'Callback',{@selectCallback,dlg.Handle});
set(h(2),'Callback',{@promoteCallback,dlg.Handle});
set(h(3),'Callback',{@demoteCallback,dlg.Handle});
set(h(4),'Callback',{@removeCallback,dlg.Handle});
pos=get(h(end),'Position');
L=pos(1)+pos(3);
pos=get(popup,'Position');
pos(3)=L;
set(popup,'Position',pos);

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
ok=h(1);
setappdata(dlg.Handle,'okButton',ok);

dlg.Hidden=false;
set(dlg.Handle,'HandleVisibility','callback');%,'CloseRequestFcn','

% manage termination
if isempty(ApplyFunction)
    waitfor(ok);
    varargout{1}=getappdata(dlg.Handle,'CurrentObject');
    delete(dlg);
else    
    %varargout{1}=dlg;
    %callback.Apply=@() applyCallback([],[],dlg.Handle);
    %callback.Close=@() closeCallback([],[],dlg.Handle);
    %varargout{2}=callback;
end

end

%% callbacks
% "db" is the dialog box handle
function changeLabel(~,~,db)

object=getappdata(db,'CurrentObject');
l=getappdata(db,'Label');
object.Label=get(l,'String');
setappdata(db,'CurrentObject',object);

end

function addCallback(~,~,db)

object=getappdata(db,'CurrentObject');
object=add(object);
setappdata(db,'CurrentObject',object);
updatePopup(db);

end

function selectCallback(~,~,db)

popup=getappdata(db,'PopupMenu');
enable=get(popup,'Enable');
if strcmp(enable,'off')
    return
end
value=get(popup,'Value');

object=getappdata(db,'CurrentObject');
target=getappdata(db,'TargetAxes');

sub=object.BoundArray{value};
sub=select(sub,target);
object.BoundArray{value}=sub;
setappdata(db,'CurrentObject',object);
updatePopup(db);

end

function promoteCallback(~,~,db)

popup=getappdata(db,'PopupMenu');
enable=get(popup,'Enable');
if strcmp(enable,'off')
    return
end
value=get(popup,'Value');

% do stuff

end

function demoteCallback(~,~,db)

popup=getappdata(db,'PopupMenu');
enable=get(popup,'Enable');
if strcmp(enable,'off')
    return
end
value=get(popup,'Value');

% do stuff

end

function removeCallback(~,~,db)

popup=getappdata(db,'PopupMenu');
enable=get(popup,'Enable');
if strcmp(enable,'off')
    return
end
value=get(popup,'Value');

object=getappdata(db,'CurrentObject');
object=remove(object,value);
setappdata(db,'CurrentObject',object);
updatePopup(db);

end

function okCallback1(~,~,db)

ok=getappdata(db,'okButton');
delete(ok);

end

function cancelCallback(~,~,db)

setappdata(db,'CurrentObject',getappdata(db,'PreviousObject'));
ok=getappdata(db,'okButton');
delete(ok);

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
value=get(popup,'Value');
if value>1
    value=value-1;
end

N=numel(object.BoundArray);
if N==0
    set(popup,'String','(none)','Enable','off');
else
    choice=cell(1,N);
    for n=1:N
        choice{n}=sprintf('%d: %s',n,object.BoundArray{n}.Label);
    end
    set(popup,'Value',value,'String',choice,'Enable','on');
end


end