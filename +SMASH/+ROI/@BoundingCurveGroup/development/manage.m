% interactively manage BoundingCurveGroup objects
%
%

function varargout=manage(object,target,varargin)

% manage input
if (nargin<2) || isempty(target)
    target=gca;
end

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
advanced=struct('ApplyFunction',[],'DeleteOnClose',true,...
    'GroupHandle',[]);
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid name');
    if isfield(advanced,name)
        advanced.(name)=varargin{n+1};
    else
        error('ERROR: invalid name');
    end    
end

if ischar(advanced.ApplyFunction)
    advanced.ApplyFunction=str2func(advanced.ApplyFunction);
end
assert(isempty(advanced.ApplyFunction)...
    | isa(advanced.ApplyFunction,'function_handle'),...
    'ERROR: invalid AppyFunction');
ApplyFunction=advanced.ApplyFunction;

assert(islogical(advanced.DeleteOnClose),...
    'ERROR: DeleteOnClose must be logical');
DeleteOnClose=advanced.DeleteOnClose;

if isempty(advanced.GroupHandle)
    advanced.GroupHandle=view(object,target);
end

% create dialog
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='BoundingCurveGroup manager';
%set(dlg.Handle,'NextPlot','new');

setappdata(dlg.Handle,'PreviousObject',object);
setappdata(dlg.Handle,'CurrentObject',object);
setappdata(dlg.Handle,'TargetAxes',target);
setappdata(dlg.Handle,'GroupHandle',advanced.GroupHandle);

addblock(dlg,'text','BoundingCurveGroup manager');

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

popup=getappdata(db,'PopupMenu');
choice=get(popup,'String');
set(popup,'Value',numel(choice));

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

sub=object.Children{value};
sub=select(sub,target);
object.Children{value}=sub;
setappdata(db,'CurrentObject',object);
updatePopup(db);

end

function promoteCallback(~,~,db)

popup=getappdata(db,'PopupMenu');
enable=get(popup,'Enable');
if strcmp(enable,'off')
    return
end
index=get(popup,'Value');

object=getappdata(db,'CurrentObject');
object=promote(object,index);
setappdata(db,'CurrentObject',object);
if index>1
    index=index-1;
end
set(popup,'Value',index);
updatePopup(db)

end

function demoteCallback(~,~,db)

popup=getappdata(db,'PopupMenu');
enable=get(popup,'Enable');
if strcmp(enable,'off')
    return
end
index=get(popup,'Value');

object=getappdata(db,'CurrentObject');
object=demote(object,index);
setappdata(db,'CurrentObject',object);
if index<numel(object.Children)
    index=index+1;
end
set(popup,'Value',index);
updatePopup(db)

end

function removeCallback(~,~,db)

popup=getappdata(db,'PopupMenu');
enable=get(popup,'Enable');
if strcmp(enable,'off')
    return
end
index=get(popup,'Value');

object=getappdata(db,'CurrentObject');
object=remove(object,index);
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

N=numel(object.Children);
if N==0
    set(popup,'String','(none)','Enable','off');
else
    choice=cell(1,N);
    for n=1:N
        choice{n}=sprintf('%d: %s',n,object.Children{n}.Label);        
    end
    if value>N
        value=N;
    end
    set(popup,'Value',value,'String',choice,'Enable','on');
end

group=getappdata(db,'GroupHandle');
for n=1:N
    hline=findobj(group(n),'Type','line');
    if n==curent
        set(hline,'LineWidth',2);
    else
        et(hline,'LineWidth',0.5);
    end
end

end

function updateDialog(db)

object=getappdata(db,'CurrentObject');


end