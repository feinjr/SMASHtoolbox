% bound Control object boundaries
%
%     >> object=bound(object,'add',[name]);
%     >> object=bound(object,'rename',index,name);
%
%     >> object=bound(object,'define',index,table);
%     >> object=bound(object,'select',index,[target]);
%
%     >> object=bound(object,'order',array);
%
%     >> bound(object,'summarize');
%
%     >> object=bound(object,'copy',index);
%
%     >> object=bound(object,'remove',array);
%
%

%
%

function varargout=bound(object,operation,varargin)

% manage input
%assert(nargin>=2,'ERROR: insufficient input');
if nargin<2
    operation='manage';
end
assert(ischar(operation),'ERROR: invalid operation');

if nargin<3
    index=[];
end

% verify index
IndexList=1:numel(object.Boundary);
    function verifyIndex(array)
        for k=1:numel(array)
            assert(any(index(k)==IndexList),'ERROR: invalid index request');
        end
    end

% perform requested operation
Narg=numel(varargin);
switch lower(operation)
    case 'add'
       object.Boundary{end+1}=SMASH.ROI.BoundingCurve('horizontal');
       if (Narg>=1) 
           name=varargin{1};
           assert(ischar(name),'ERROR: invalid name');
           object.Boundary{end}.Label=name;
       end
    case 'rename'
        assert(Narg==2,'ERROR: invalid number of inputs');
        index=varargin{1};
        verifyIndex(index);
        assert(isscalar(index),'ERROR: invalid index');
        name=varargin{2};
        assert(ischar(name),'ERROR: invalid name');
        object.Boundary{index}.Label=name;
    case 'define'
        assert(Narg>1,'ERROR: invalid number of inputs');
        index=varargin{1};
        verifyIndex(index);
        assert(isscalar(index),'ERROR: invalid index');
        varargin=varargin(2:end);
        object.Boundary{index}=define(object.Boundary{index},varargin{:});
    case 'select'
        if Narg==0
            % under construction
        end
        assert(Narg>=1,'ERROR: invalid number of inputs');
        index=varargin{1};
        verifyIndex(index);
        assert(isscalar(index),'ERROR: invalid index');
        if Narg>=2
            target=varargin{2};
        else
            preview(object);
            target=gca;
        end
        object.Boundary{index}=select(object.Boundary{index},target);
    case 'copy'
        assert(Narg>1,'ERROR: invalid number of inputs');
        index=varargin{1};
        verifyIndex(index);
        assert(isscalar(index),'ERROR: invalid index');
        object.Boundary{end+1}=object.Boundary{index};
        name=sprintf('Copy of %s',object.Boundary{index}.Label);
        object.Boundary{end}.Label=name;
    case 'order'    
        assert(Narg>1,'ERROR: invalid number of inputs');
        array=varargin{1};
        verifyIndex(array);
        try
            index=reshape(index,size(IndexList));
            assert(all(sort(index)==IndexList),'ERROR');
        catch
            error('ERROR: invalid order array');
        end        
        object.Boundary=object.Boundary(index);
    case 'summarize'
        if isempty(object.Boundary)
            fprintf('No defined boundaries \n');
        else            
            N=numel(object.Boundary);
            if Narg==0
                list=1:N;
                fprintf('There %d defined boundaries\n',N);
            elseif Narg==1
                list=varargin{1};
                verifyIndex(list);
                fprintf('There %d defined boundaries (%d shown)\n',N,numel(list));
            else
                error('ERROR: too many inputs');
            end           
            for n=list
                fprintf('%3d : %s\n',n,object.Boundary{n}.Label);
            end
        end
    case 'remove'
        assert(Narg==1,'ERROR: invalid number of inputs');
        array=varargin{1};
        verifyIndex(array);
        array=unique(array);       
        N=numel(object.Boundary); 
        keep=true(1,N);
        for n=1:N
            if any(n==array)
                keep(n)=false;
            end
        end
        object.Boundary=object.Boundary(keep);
    case 'manage'
        if isempty(object.Preview)
            object=preview(object);
        end
        preview(object);
        target=gca;
        object.Boundary=manage(object.Boundary,target);
    otherwise
        error('ERROR: invalid operation requested');
end

% manage output
if nargout>0
    varargout{1}=object;
end

end

% interactive boundary management
function object=manage(object,target)

% local variables
fig=ancestor(target,'figure');
set(fig,'CloseRequestFcn','');
local=object;
current=1;

% create dialog
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Manage boundaries';

choose=addblock(dlg,'popup','Current boundary:',{''});
set(choose(2),'Callback',@chooseBoundary);
    function chooseBoundary(varargin)
        N=numel(local);
        if N<1
            return
        end
        current=get(choose(2),'Value');
        set(name(2),'String',local{current}.Label);
    end

name=addblock(dlg,'edit_button',{'Name:','Save'},20);
set(name(end),'Callback',@updateName)
    function updateName(varargin)
        local{current}.Label=get(name(2),'String');
    end

h=addblock(dlg,'button',{'Select','Promote','Demote'});
set(h(1),'Callback',@selectBoundary)
    function selectBoundary(varargin)
        local{current}=select(local{current},[target dlg.Handle]);
    end

set(h(2),'Callback',@promoteBoundary)
    function promoteBoundary(varargin)
        if isempty(local)
            return
        end
        if current>1
            index=1:numel(local);
            index(current-1)=current;
            index(current)=current-1;
            local=local(index);
            current=current-1;
            updateList;
        end        
    end
set(h(3),'Callback',@demoteBoundary)
    function demoteBoundary(varargin)
        if isempty(local)
            return
        end
        if current<numel(local)
            index=1:numel(local);
            index(current+1)=current;
            index(current)=current+1;
            local=local(index);
            current=current+1;
            updateList;
        end        
    end

new=addblock(dlg,'button','Remove current',15);
set(new,'Callback',@removeBoundary);
    function removeBoundary(varargin)
        if isempty(local)
            return
        end
        local=local([1:(current-1) (current+1):end]);
        current=current-1;
        if current==0
            current=1;
        end
        updateList;
    end

new=addblock(dlg,'button','New boundary',15);
set(new,'Callback',@newBoundary);
    function newBoundary(varargin)        
        local{end+1}=SMASH.ROI.BoundingCurve('horizontal');
        current=numel(local);
        updateList;        
    end

h=addblock(dlg,'button',{'OK','Cancel'});
set(h(1),'Callback',@done);
    function done(varargin)
        object=local;
        delete(dlg);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)
        delete(dlg);
    end

updateList;
dlg.Hidden=false;
%dlg.Modal=true;

% wait for user
uiwait(dlg.Handle);
delete(fig);

% helper function
    function updateList()
        if isempty(local)
            set(choose(2),'String',{'(none)'})
            set(name(2),'String','');
            return
        end
        label=cell(size(local));
        for k=1:numel(label)
            label{k}=sprintf('Boundary #%d',k);
        end
        set(choose(2),'String',label,'Value',current);        
        set(name(2),'String',local{current}.Label);
    end

end