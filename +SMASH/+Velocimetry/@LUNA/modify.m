
function object=modify(object,step,range)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(isnumeric(step) && isscalar(step) && (step>0),...
    'ERROR: invalid step');

if (nargin<3) || isempty(range)
    range=[max(object.Time) min(object.Time)];
end
assert(isnumeric(range) && numel(range)==2 && (diff(range)~=0),...
    'ERROR: invalid range');
range=sort(range);
range(1)=max(range(1),object.Time(1));
range(2)=min(range(2),object.Time(end));

% time revision 
dt=(object.Time(end)-object.Time(1))/(numel(object.Time)-1);
y=object.LinearAmplitude;
if step>dt
    sigma=4*(step/dt);
    L=3*round(sigma);
    x=-L:L;
    weight=exp(-x.^2/(2*sigma^2));
    weight=weight(:)/sum(weight);
    y=conv(y,weight,'same');    
end

t=range(1):step:range(2);
y=interp1(object.Time,y,t,'linear');

% store results
object.Time=t;
object.LinearAmplitude=y;
object.IsModified=true;

end