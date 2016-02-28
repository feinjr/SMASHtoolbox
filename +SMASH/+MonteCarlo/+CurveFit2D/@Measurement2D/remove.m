% UNDER CONSTRUCTION
%

%
% created ??? by Daniel Dolan (Sandia National Laboratories)
%
function object=remove(object,index)

% manage input
assert(nargin>1,'ERROR: insufficient number of inputs');

if strcmpi(index,'all')
    object.ProbabilityDensity={};
    object.NumberMeasurements=0;
    return    
end

% remove requested measurements
valid=1:object.NumberMeasurements;
keep=true(object.NumberMeasurements,1);
for k=1:numel(index)
    assert(any(index(k)==valid),'ERROR: invalid index');
    keep(index)=false;
end

object.ProbabilityDensity=object.ProbabilityDensity(keep);
object.NumberMeasurements=sum(keep);

end