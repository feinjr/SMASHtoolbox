%
%     >> object=setup(object,curve,param,bound)
function object=setup(object,curve,parameter,bound)

% manage input
assert(nargin>=3,'ERROR: insufficient input');

if ischar(curve)
    curve=str2func(curve);
end
assert(isa(curve,'function_handle'),'ERROR: invalid curve function');

assert(isnumeric(parameter),'ERROR: invalid parameter setting');
N=numel(parameter);
parameter=reshape(parameter,[1 N]);

if (nargin<4) || isempty(bound)
    bound=repmat([-1; +1;],[1 N]);
    bound=bound*inf;
end
assert(size(bound,1)==2,'ERROR: invalid bound setting');
assert(size(bound,2)==N,'ERROR: invalid bound setting');

% assign properties
object.Function=curve;
object.Parameter=parameter;
object.bound=bound;

end