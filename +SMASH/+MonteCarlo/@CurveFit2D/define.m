% define Define model function
%
% This method defines the model function used in a 2D curve fit.%
%    object=define(object,model,param);
% (documentation under construction)
%    object=define(object,model,param,bound);
% Empty values can be used as placed holders when changing parameters
% and/or bounds while leaving earlier parameters unchanged.
%    object=define(object,[],param);
%

%
%
%
function object=define(object,model,param,bound)

% manage input
assert(nargin>=3,'ERROR: insufficient input');

if isempty(model)
    model=object.Model;
elseif ischar(model)
    model=str2func(model);
end
assert(isa(model,'function_handle'),'ERROR: invalid model function');
object.Model=model;

if isempty(param)
    param=object.Parameter;
end
assert(isnumeric(param),'ERROR: invalid parameter value');
object.Parameter=param;

N=numel(param);
DefaultBound=nan(N,2);
DefaultBound(:,1)=-inf;
DefaultBound(:,2)=+inf;    
if nargin<4
    bound=object.Bound;
end
if isempty(bound)
    bound=DefaultBound;    
end
assert(isnumeric(bound) && ismatrix(bound) && (size(bound,2)==2),...
    'ERROR: invalid bound table')
bound=sort(bound,2);
if size(bound,1) ~= N
    bound=DefaultBound;
    warning('SMASH:CurveFit2D',...
        'Resetting bound table for consistency with parameters');
end   
object.Bound=bound;

% determine slack variables 
N=numel(param);
object.Slack=nan(size(param));
for n=1:N
    assert((param(n)>=bound(n,1)) && (param(n)<=bound(n,2)),...
        'ERROR: specified parameter(s) fall outside specified bounds');
    if all(isinf(bound(n,:))) % unbounded parameter
        object.Slack(n)=param(n);
    elseif isinf(bound(n,1)) % maximum bound
        object.Slack(n)=sqrt(bound(n,2)-param(n));
    elseif isinf(bound(n,2)) % minimum bound
        object.Slack(n)=sqrt(param(n)-bound(n,1));
    else % two-sided bound
        mid=(bound(n,2)+bound(n,1))/2;
        amp=(bound(n,2)-bound(n,1))/2;
        object.Slack(n)=asin((param(n)-mid)/amp);
    end
end

% evaluate function and update object
object=evaluate(object,'parameter',param);
object.Parameter=param;
object.Bound=bound;

object.Optimized=false;

end