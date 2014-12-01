
function result=subsref(object,s,varargin)

% handle property access
if strcmp(s.type,'.') && ischar(s.subs)
    name=s.subs;
    if isprop(object,name)
        result=object.(s.subs);
        return
    else
        error('ERROR: invalid property');
    end
end

if strcmp(s.type,'()') && numel(s.subs)==1
    index=s.subs{1};
elseif strcmp(s.type,'.')
    
    return
else
    error('ERROR: invalid index')
end

% create new object based on index
x=object.Grid;
N=numel(x);
if islogical(index) && (numel(index)==N)
    keep=x(index);
    object.Grid=object.Grid(keep);
    object.Data=object.Data(keep);
elseif isnumeric(index) && all(index>0) && all(index<=N) && all(index==floor(index))
    object.Grid=object.Grid(index);
    object.Data=object.Data(index);
else
    error('ERROR: invalid index')
end

end