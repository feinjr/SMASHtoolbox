% merge namespaces
%    >> object=merge(object1,object2,...);
%

%
%
%
function object=merge(object,varargin)

% handle input
assert(nargin>=2,'ERROR: insufficient number of inputs');

% merge results
for n=1:numel(varargin)
    switch class(varargin{n})
        case 'SMASH.System.namespace'
            temp=[object.Names varargin{n}.Names];
            object.Names=temp;
            temp=[object.Handles varargin{n}.Handles];
            object.Handles=temp;
        otherwise
            error('ERROR: invalid merge source');
    end
end

end