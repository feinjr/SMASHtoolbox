% checkGrid Determine if an object has a uniformly spaced grid
%
% This method determines if a Signal object has uniformly spaced Grid
% values.  Uniformity is determined by comparing the average grid spacing with
% the actual spacing.  If any actual spacing differs from the average by
% more than the object's UniformGridThreshold, a logical false (0) is
% returned; otherwise, a logical true (1) is returned.
%
% See also Signal
%

%
% created NOvember 15, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=checkGrid(object,threshold)

% handle input
if (nargin<2) || isempty(threshold)
    threshold=1e-6;
end

% analyze grid
x=object.Grid;
dxmean=(max(x)-min(x))/(numel(x)-1);
dx=abs(diff(x));
L=abs(dx-dxmean);
if any(L>threshold)
    object.UniformGrid=false;
else
    object.UniformGrid=true;
end

end