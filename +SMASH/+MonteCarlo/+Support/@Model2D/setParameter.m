% setParameter Set parameter values and bounds
%
% This method sets values and bounds for parameters in a Model2D object.
% Parameters are modified one at a time by index (first parameter is 1,
% etc.).
%     object=setParameter(object,index,value,bound);
%        value : new parameter setting (scalar)
%        bound : new bound setting (1x2 array)
% Passing empty values preserves the current value/bound setting.
%     object=setParameter(object,index,[],bound); % modify bound only
%     object=setParameter(object,index,value,[]); % modify value only
% Inconsistent value/bound settings will generate an error.
% 
% Three types of parameter bounds are supported.  Unconstrained parameters
% use the bound array [-inf +inf].  Parameters constrained on one side mix
% finite and infinite values: [-inf a] or [a +inf].  Parameters constrained
% on both sides use two bounds: [a b].
%
% Each parameter is assigned a slack variable for constraint management.
%     -For unconstrained parameters, the slack variable represent the
%     parameter change (positive or negative) during optimization.  
%     -For one-sided constraints, the square of the slack variable
%     represents the difference between the constraint and the parameter.
%     -For two-side constraints, the slack variable is the argument of a
%     sinusoid whose minimum and maximum values match the parameter limits.
% Slack variables are automatically updated whenever a parameter or its
% constraints are modified.
%
% See also Model2D, optimize
%

%
% created October 29, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=setParameter(object,index,value,bound)

% manage input
assert(nargin>=3,'ERROR: insufficient input');

valid=1:object.NumberParameters;
assert(any(index==valid),'ERROR: invalid parameter index');

if isempty(value)
    value=object.Parameters(index);
end

if (nargin<4) || isempty(bound)
    bound=object.Bounds(index,:);
end
assert(isnumeric(bound) && numel(bound)==2,'ERROR: invalid parameter bound');
bound=sort(bound);
assert((bound(2)-bound(1))>0,'ERROR: invalid parameter bound');

% make sure bounds contain the value
p0=value;
assert((p0>=bound(1)) && (p0<=bound(2)),...
    'ERROR: value outside of parameter bound');
object.Parameters(index)=value;

% update parameter bound
object.Bounds(index,1)=bound(1);
object.Bounds(index,2)=bound(2);

if all(isinf(bound))
    object.SlackFunction{index}=@(q) p0+q;
    q0=0;
elseif isinf(bound(1))
    object.SlackFunction{index}=@(q) bound(2) - q.^2;
    q0=sqrt(bound(2)-p0);
elseif isinf(bound(2))
    object.SlackFunction{index}=@(q) bound(1) + q.^2;
    q0=sqrt(p0-bound(1));
else
    L=(bound(2)-bound(1))/2;
    pmid=(bound(2)+bound(1))/2;
    qmid=-asin((p0-pmid)/L);
    object.SlackFunction{index}=@(q) pmid+L*sin(q-qmid);
    q0=0;
end
object.SlackVariables(index)=q0;

end