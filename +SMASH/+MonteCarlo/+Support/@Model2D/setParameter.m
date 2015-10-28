% setParameter Set parameter value and/or bounds
%
%     object=setParameter(object,index,value,span);
% UNDER CONSTRUCTION
%
% See also Model2D
%

%
%
%
function object=setParameter(object,index,value,span)

% manage input
assert(nargin>=3,'ERROR: insufficient input');

valid=1:object.NumberParameters;
assert(any(index==valid),'ERROR: invalid parameter index');

if isempty(value)
    value=object.Parameters(index);
end

if (nargin<4) || isempty(span)
    span=object.Bounds(index,:);
end
assert(isnumeric(span) && numel(span)==2,'ERROR: invalid parameter span');
span=sort(span);
assert((span(2)-span(1))>0,'ERROR: invalid parameter span');

% make sure bounds contain the value
p0=value;
assert((p0>=span(1)) && (p0<=span(2)),...
    'ERROR: value outside of parameter span');
object.Parameters(index)=value;

% update parameter bound
object.Bounds(index,1)=span(1);
object.Bounds(index,2)=span(2);

if all(isinf(span))
    object.SlackFunction{index}=@(q) p0+q;
    q0=0;
elseif isinf(span(1))
    object.SlackFunction{index}=@(q) span(2) - q.^2;
    q0=sqrt(span(2)-p0);
elseif isinf(span(2))
    object.SlackFunction{index}=@(q) span(1) + q.^2;
    q0=sqrt(p0-span(1));
else
    L=(span(2)-span(1))/2;
    pmid=(span(2)+span(1))/2;
    qmid=-asin((p0-pmid)/L);
    object.SlackFunction{index}=@(q) pmid+L*sin(q-qmid);
    q0=0;
end
object.SlackVariables(index)=q0;

end