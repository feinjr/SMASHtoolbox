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
assert(nargin>=2,'ERROR: insufficient input');
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
    otherwise
        error('ERROR: invalid operation requested');
end

% manage output
if nargout>0
    varargout{1}=object;
end

end