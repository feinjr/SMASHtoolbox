% isGridUniform Determine if an object has a uniformly spaced grid
%
% This method determines if a Signal object has uniformly spaced Grid
% values.  This is determined by comparing the average grid spacing with
% the actual spacing.  If any actual spacing differs from the average by
% more than the object's UniformGridThreshold, a logical false (0) is
% returned; otherwise, a logical true (1) is returned.
%
% See also Signal, makeGridUniform
%

%
% created October 30, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function result=isGridUniform(object)

% persistent UniformThreshold
% if isempty(UniformThreshold)
%     UniformThreshold=1e-6;
% end
% 
% % handle input
% if (nargin<2) || isempty(threshold)
%     threshold=UniformThreshold;
% elseif isnumeric(threshold) && isscalar(threshold) && (threshold>0)
%     UniformThreshold=threshold;
% else
%     error('ERROR: invalid threshold specified');
% end

% switch object.Precision
%     case 'double'
%         threshold=1e-9;
%     case 'single'        
%         threshold=1e-3;
% end

% probe grid uniformity
x=object.Grid;
dxu=(x(end)-x(1))/(numel(x)-1);
xu=linspace(x(1),x(end),numel(x));
dx=x-reshape(xu,size(x));
if any(abs(dx/dxu)>1e-2)
    result=false;
else
    result=true;
end

% dxmean=(max(x)-min(x))/(numel(x)-1);
% dx=max(abs(diff(x)));
% L1=abs(1-dx/dxmean);
% L2=dx/(max(x)-min(x));
% if (L1<1e-3) || (L2<10*eps(object.Precision))
%     result=true;
% else
%     result=false;
% end

%L=abs(dx-dxmean)/dxmean;
%if any(L>threshold)
%    result=false;
%end

end