% UNDER CONSTRUCTION

%
% object=bound(object,bc); % add BoundaryCurve object
%
% object=bound(object,index); % sort/remove/copy existing bounds
%
% object=bound(object,'show'); % show current bounds on preview image
%

% UNDER DEVELOPMENT
% object=bound(object); % interactive selection in a new figure
% object=bound(object,target); % interactive selection in an existing axes
% bound(object,target,ApplyFunction);

function varargout=bound(object,varargin)

Narg=numel(varargin);

% manual operations
if Narg==1
    if isa(varargin{1},'SMASH.ROI.BoundingCurve') % add mode
        object.Boundary{end+1}=varargin{1};
        varargout{1}=object;
        return
    elseif isnumeric(varargin{1}) % keep/copy/sort modes
        valid=1:numel(object.Boundary);
        index=varargin{1};
        for k=1:numel(index)
            assert(any(index(k)==valid),'ERROR: invalid index value(s)');
        end
        object.Boundary=object.Boundary(index);
        varargout{1}=object;
        return
    elseif islogical(varargin{1}) % keep mode
        index=varargin{1};
        assert(numel(index)==numel(object.Boundary),...
            'ERROR: invalid logical index size');
        object.Boundary=object.Boundary(index);
        varargout{1}=object;
        return
    elseif ischar(varargin{1}) && strcmpi(varargin{1},'show')
        Nboundary=numel(object.Boundary);
        if Nboundary==0
            fprintf('No boundaries defined\n');
            return
        end
        preview(object);       
        for n=1:Nboundary
            view(object.Boundary{n},gca);
        end      
        return
    end    
end

% interactive operations
error('ERROR: interactive modes are not ready yet');
if Narg<1
    target=[];    
else  
    target=varargin{1};
end

if Narg<2
    ApplyFunction=[];
else
    ApplyFunction=varargin{2};
    if ischar(ApplyFunction)
        ApplyFunction=str2func(ApplyFunction);
    end
    assert(isa(ApplyFunction,'function_handle'),...
        'ERROR: invalid Apply function');
end

if isempty(object.Preview)
    object=preview(object,'blocks',1000);
end
if isempty(target)
    preview(object);
    fig=gcf;
    target=gca;
else
    preview(object,target);
    fig=ancestor(target,target);
end

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Boundary selection';
setappdata(dlg.Handle,'CurrentBoundary',object.Boundary);
setappdata(dlg.Handle,'PreviousBoundary',object.Boundary);
setappdata(dlg.Handle,'TargetFigure',fig);
setappdata(dlg.Handle,'TargetAxes',target);

addblock(dlg,'text','STFT boundary selection');
addblock(dlg,'text','Dynamic frequency bounds over finite time');
addblock(dlg,'text','');

h=addblock(dlg,'popup','Current boundary:',{'Boundary 1'});
makeBold(h(1));
setappdata(dlg.Handle,'Popup',h(2));
managePopup(dlg.Handle);

name={'New boundary','Edit current','Remove current'};
width=cellfun(@numel,name);
dummy=repmat('M',[1 max(width)]);
h=addblock(dlg,'button',{dummy dummy dummy});
set(h(1),'String',name{1},'Callback',{@newBoundary,dlg.Handle});
set(h(2),'String',name{2},'Callback',{@editBoundary,dlg.Handle});
set(h(3),'String',name{3},'Callback',{@removeBoundary,dlg.Handle});

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

% manage termination
if isempty(ApplyFunction)
    %waitfor(ok);
    %varargout{1}=getappdata(dlg.Handle,'CurrentObject');
else
    varargout{1}=dlg;
end

end

%% callbacks
% "db" is the dialog box handle
function newBoundary(~,~,db)

popup=getappdata(db,'Popup');
object=getappdata(db,'CurrentObject');

object{end+1}=SMASH.ROI.BoundingCurve;
setappdata(db,'CurrentObject',object);
managePopup(db);
set(popup,'Value',numel(object));

%editBoundary([],[],db);

end

function editBoundary(~,~,db)

object=getappdata(db,'CurrentObject');
popup=getappdata(db,'Popup');
choice=get(popup,'Value');
target=getappdata(db,'TargetAxes');

sub=getappdata(db,'SubDialog');
if ~isempty(sub)
    delete(sub);
end
sub=select(object{choice},target,@subApply);
    function subApply(current)
        object=getappdata(db,'CurrentObject');
        object{choice}=current;
        setappdata(db,'CurrentPoint',object);
        position=get(sub.Handle,'Position');
        setappdata(db,'SubPosition',position);
    end
position=getappdata(db,'SubPosition');
if ~isempty(position)
    set(sub.Handle,'Position',position);
end

end

function removeBoundary(~,~,db)

popup=getappdata(db,'Popup');
choice=get(popup,'Value');
object=getappdata(db,'CurrentObject');
index=[1:(choice-1) (choice+1):numel(object)];
if choice>1
    choice=choice-1;
end
set(popup,'Value',choice);
object=object(index);
setappdata(db,'CurrentObject',object);
managePopup(db);

end

%% helper functions
function makeBold(target)

set(target,'FontWeight','bold');
extent=get(target,'Extent');
position=get(target,'Position');
position(3)=extent(3);
set(target,'Position',position);

end

function managePopup(db)

popup=getappdata(db,'Popup');
boundary=getappdata(db,'CurrentObject');
N=numel(boundary);
if N>0
    entry=cell(1,N);
    for n=1:N
        entry{n}=sprintf('Record #%d',n);
    end
    set(popup,'Enable','on','String',entry);
else
   entry={'[none]'};
   set(popup,'Enable','off','String',entry);
end  

end