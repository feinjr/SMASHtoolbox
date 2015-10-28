% evaluate Evaluate the model for a specified parameter state
%
% [table,param]=evaluate(object,state,mode);
%
% UNDER CONSTRUCTION
%

%
%
%
function [object,param]=evaluate(object,param,xspan,yspan,mode)

% manage input
assert(nargin>=4,'ERROR: insufficient input');
assert(numel(param)==object.NumberParameters,...
    'ERROR: invalid number of parameters');

if (nargin<5) || isempty(mode)
    mode='slack';
end
assert(ischar(mode),'ERROR: invalid evaluation mode');

% translate variables
if strcmp(mode,'slack')
    for n=1:object.NumberParameters
        param(n)=object.SlackFunction{n}(param(n));
    end
end

% evaluate function
table=object.Function(param,xspan,yspan);
object.Curve=reset(object.Curve,table);