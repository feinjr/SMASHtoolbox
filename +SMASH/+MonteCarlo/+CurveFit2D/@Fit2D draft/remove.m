% remove Remove measurement cloud(s)
%
% This method removes measurement clouds from a CloudFit2D object.
%    >> object=remove(object,index);
% Clouds are referenced in the order they were added.
%
% See also CloudFit2D, addMeasurement
%

%
% created October 28, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=remove(object,index)

% manage input
assert(nargin>1,'ERROR: insufficient number of inputs');
valid=1:object.NumberMeasurements;
keep=true(object.NumberMeasurements,1);
for k=1:numel(index)
    assert(any(index(k)==valid),'ERROR: invalid index');
    keep(index)=false;
end

% update cloud data
object.Measurement=object.Measurement(keep);
object.NumberMeasurements=sum(keep);
object.IsProcessed=object.IsProcessed(keep);

end