% add Add point 
%
% This method adds a single point to LineSegments object.
%     >> object=add(object,coordinates,index);
% If no index is specified, the point is added at the end position.
%
% See also remove, reset
%

%
% created October 23, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=add(object,coordinates,index)

% mange input
assert(nargin>=2,'ERROR: insufficient input');

assert(isnumeric(coordinates) && ismatrix(coordinates) && ~isempty(coordinates),...
    'ERROR: invalid coordinate matrix');
[Nrow,Ncol]=size(coordinates);
assert(Nrow==1,'ERROR: points must be added one at a time');
assert(Ncol==object.NumberDimensions,...
    'ERROR: incompatible coordinate array');

if (nargin<3) || isempty(index)
    index=object.NumberPoints+1;
end
assert(isnumeric(index),'ERROR: invalid index specified')
assert(numel(index)==Nrow,'ERROR: inconsistent index specified');

% add data and reset object
data=nan(object.NumberPoints+1,object.NumberDimensions);
k=1:(index-1);
data(k,:)=object.Points(k,:);
data(index,:)=coordinates;
data((index+1):end,:)=object.Points(index:end,:);

object=reset(object,data);

end