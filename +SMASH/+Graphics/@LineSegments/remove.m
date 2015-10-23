% remove Remove point
%
% This method removes a single point from a LineSegments object.
%     >> object=remove(object,index);
%
% See also remove, add
%

%
% created October 23, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=remove(object,index)

% manage input
assert(nargin>1,'ERROR: no index specified');
assert(nargin==2,'ERROR: too many inputs');

assert(isnumeric(index),'ERROR: invalid index');
assert(isscalar(index),'ERROR: points must be removed one at a time');
valid=1:object.NumberPoints;
assert(any(index==valid),'ERROR: invalid index');

% remove point
keep=[1:(index-1) (index+1):object.NumberPoints];
data=object.Points(keep,:);
object=reset(object,data);

end