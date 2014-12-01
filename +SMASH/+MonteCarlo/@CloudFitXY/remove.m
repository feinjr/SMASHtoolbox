% remove Remove data points
%
% This method permanently removes data points from a CloudFitXY object.
%    >> object=remove(object,index);
% Data points are referenced in the order they were added.
%
% See also CloudFitXY, add
%

%
% created October 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%%

function object=remove(object,index)

assert(nargin>1,'ERROR: insufficient number of inputs');
valid=1:object.NumberClouds;
for k=1:numel(index)
    assert(any(index(k)==valid),'ERROR: invalid index');
end
keep=valid(~index);

object.Clouds=object.Clouds(keep);
object.ActiveClouds=object.ActiveClouds(keep);
object.NumberClouds=numel(object.Clouds);



end