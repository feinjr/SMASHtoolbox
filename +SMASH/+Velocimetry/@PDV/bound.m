% bound Control analysis boundaries
%
% This method controls the boundaries used to guide history analysis.
% Boundaries are stored in the Boundary property of a PDV object.  This
% property cannot be modified directly, but can be revised as shown below.
%     >> object=bound(object); % default mode is "mangage"
%     >> object=bound(object,'manage'); % interactive boundary management
% Interactive boundary management generates shows a preview of the object
% and generates a dialog box where boundaries can be added, edited, and
% removed.  Pressing the "OK" button saves object revisions, while pressing
% the "Cancel" button preserves the original boundary settings.
%
% Various other modes provide advanced boundary control.  New boundaries
% are generated with 'add' mode.
%     >> object=bound(object,'add'); % default name is "Boundary curve"
%     >> object=bound(object,'add',name); % specify name at creation
%     >> object=bound(object,'add',existing); % add existing BoundingCurve object
% New boundaries are added at the end of the current boundary list.
% Exisiting boundaries are accessed by numeric index, which are revealed in
% 'summarize' mode.
%     >> bound(object,'summarize'); % list printed in command window
%
% The name associated with a boundary can be changed in 'rename' mode.
%     >> object=bound(object,'rename',index,name);
% The data in a boundary can be manually defined or selected interactively.
%     >> object=bound(object,'define',index,table); % Nx3 table
%     >> object=bound(object,'select',index); % select points in current axes
%     >> object=bound(object,'select',index,[target]); % select points in target axes
% An existing boundary can be copied as a new boundary (at the end of the
% list).
%     >> object=bound(object,'copy',index);
% Boundaries can be removed with a single index or an array of indices.
%     >> object=bound(object,'remove',1); % remove first boundary
%     >> object=bound(object,'remove',array);
% Boundary order can be revised by passing an array of index values in the
% desired order (all valid indices must be listed).
%     >> object=bound(object,'order',array);
%
% See also PDV
%

%
% created February 18, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=bound(object,operation,varargin)

% manage input
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
            assert(any(array(k)==IndexList),'ERROR: invalid index request');
        end
    end

% perform requested operation
Narg=numel(varargin);
switch lower(operation)
    case 'add'
       object.Boundary{end+1}=SMASH.ROI.BoundingCurve('horizontal');
       if Narg>=1 
           if ischar(varargin{1})
               object.Boundary{end}.Label=varargin{1};
           elseif isa(varargin{1},'SMASH.ROI.BoundingCurve')
               object.Boundary{end}=varargin{1};
           else
              error('ERROR: invalid "add" input');
           end
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
                if N==1
                    fprintf('There is %d defined boundary\n',N); 
                else
                    fprintf('There are %d defined boundaries\n',N);
                end               
            elseif Narg==1
                list=varargin{1};
                verifyIndex(list);
                fprintf('There are %d defined boundaries (%d shown)\n',...
                    N,numel(list));
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

h=addblock(dlg,'text','Boundary curve management');
set(h,'FontWeight','bold');

choose=addblock(dlg,'popup_button',{'Boundary curve list:' ' New '},{''},30);
set(choose(2),'Callback',@chooseBoundary);
    function chooseBoundary(varargin)
        N=numel(local);
        if N<1
            return
        end
        current=get(choose(2),'Value');
        %set(name(2),'String',local{current}.Label);
        updateBoundary;
    end
set(choose(3),'Callback',@newBoundary,'ToolTipString','Add new boundary curve');
    function newBoundary(varargin)        
        local{end+1}=SMASH.ROI.BoundingCurve('horizontal');
        current=numel(local);
        updateList;        
    end

h=addblock(dlg,'button',{'Select','Promote','Demote','Remove'});
set(h(1),'Callback',@selectBoundary,...
    'ToolTipString','Select curve points on the preview image')
    function selectBoundary(varargin)
        hline=findobj(target,'Tag','CurrentBoundaryDisplay');
        if ishandle(hline)
            delete(hline);
        end
        if isempty(local)
            return
        end
        local{current}=select(local{current},[target dlg.Handle]);
        updateBoundary;
        updateList;
    end

set(h(2),'Callback',@promoteBoundary,...
    'ToolTipString','Move boundary curve up the list')
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
set(h(3),'Callback',@demoteBoundary,...
    'ToolTipString','Move boundary curve down the list')
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

set(h(4),'Callback',@removeBoundary,...
    'ToolTipString','Remove boundary curve from the list');
    function removeBoundary(varargin)
        if isempty(local)
            return
        end
        answer=questdlg('Remove current boundary?','Remove boundary','Yes','No','No');
        if strcmpi(answer,'No')
            return
        end
        local=local([1:(current-1) (current+1):end]);
        current=current-1;
        if current==0
            current=1;
        end
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
locate(dlg,'Center',fig);
dlg.Hidden=false;
%dlg.Modal=true;

% wait for user
uiwait(dlg.Handle);
delete(fig);

% helper function
    function updateList()
        if isempty(local)
            set(choose(2),'String',{'(none defined)'})
            %set(name(2),'String','');
            return
        end
        label=cell(size(local));
        for k=1:numel(label)
            %label{k}=sprintf('Boundary #%d',k);
            label{k}=sprintf('%2d: %s',k,local{k}.Label);
        end
        set(choose(2),'String',label,'Value',current);        
        %set(name(2),'String',local{current}.Label);
        updateBoundary;
    end
    function updateBoundary()
        hline=findobj(target,'Tag','CurrentBoundaryDisplay');
        if ishandle(hline)
            delete(hline);
        end
        hline=view(local{current},target);
        set(hline,'Tag','CurrentBoundaryDisplay');
    end

end