% CROP Crop Grid range
%
% This method crops SignalGroup objects, disposing all information outside
% of the specified Grid bound.
%    >> new=crop(object,bound);
% The "bound" input must be an array specifing the minimum and maximum Grid
% values of the crop region.  All grid points inside this region are passed
% to new object.
% 
% See also Signal, limit
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=crop(object,bound)

% handle input
if nargin<2
    error('ERROR: crop bounds are required');
end

if isempty(bound) || (numel(bound)~=2)
    error('ERROR: two bound values are needed');
end
bound=sort(bound);

% crop the object
keep=(object.Grid>=bound(1)) & (object.Grid<=bound(2));
object.Grid=object.Grid(keep);
object.Data=object.Data(keep);
object.LimitIndex='all';

object=updateHistory(object);

end