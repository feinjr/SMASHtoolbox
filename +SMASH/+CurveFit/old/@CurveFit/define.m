% define Define curve fit data
%
function object=define(object,varargin)

% handle input
Narg=numel(varargin);
if (Narg==1) && isnumeric(varargin{1})
    table=varargin{1};
    Ncol=size(table,2);
    assert(Ncol==2,'ERROR: invalid data table');
elseif (Narg==2) && isnumeric(varargin{1}) && isnumeric(varargin{2})
    x=varargin{1};
    y=varargin{2};
    assert(numel(x)==numel(y),'ERROR: incompatible data');
    table=[x(:) y(:)];
else
    error('ERROR: invalid input');
end
object.Data=table;

assert(isnumeric(table),'ERROR: invalid data table');
N=size(table,2);
assert(N==2,'ERROR: invalid data table');

object=reset(object);

end