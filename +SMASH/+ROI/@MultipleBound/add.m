% object=add(object,bound);
% object=add(object,bound1,bound2,...);
%
% object=add(object); % 

function object=add(object,varargin)

% handle input
if nargin==1 % not recommended!
    allowed=object.Allowed;
    assert(numel(allowed)==1,'ERROR: automatic add not possible here');
    name=sprintf('SMASH.ROI.%s',allowed{1});
    varargin{1}=feval(name);
end

Narg=numel(varargin);
if Narg>1
    for n=1:Narg
        object=add(object,varargin{n});
    end
    return
end

% verify boundary type
bound=varargin{1};
type=class(bound);
match=regexp(type,'[.]');
if numel(match)>0
    match=match(end);
    type=type(match+1:end);
end

match=false;
for n=1:numel(object.Allowed)
    if strcmp(type,object.Allowed{n})
        match=true;
        break
    end
end
assert(match,'ERROR: %s not allowed here',type);

% add bound
object.BoundArray{end+1}=bound;

end