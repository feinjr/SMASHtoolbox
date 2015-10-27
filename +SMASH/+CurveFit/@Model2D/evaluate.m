% evaluate Evaluate the model for a specified parameter state
%
% [table,param]=evaluate(object,state,mode);
%
% UNDER CONSTRUCTION
%

%
%
%
function [object,param]=evaluate(object,state,mode)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(numel(state)==object.NumberParameters,...
    'ERROR: invalid number of parameters');

if (nargin<3) || isempty(mode)
    mode='slack';
end
assert(ischar(mode),'ERROR: invalid evaluation mode');

% translate variables
param=state;
if strcmp(mode,'slack')
    for n=1:object.NumberParameters
        param(n)=object.SlackFunction{n}(state(n));
    end
end

% evaluate function
table=object.Function(param);
object.Curve=reset(object.Curve,table);