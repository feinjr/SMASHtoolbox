% REGRID Transfer SignalGroup object onto a new grid
%
% This method interpolates an existing object into a new object on a
% specified grid.
%    >> new=regrid(object,x);
% If no grid is specified, a uniformly spaced grid is calculated from the
% existing grid.
%    >> object=regrid(object);
% This technique may needed before using methods requiring a uniformly
% spaced grid (such as fft).
%
% See also SignalGroup, lookup
%

%
% created November 24, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=regrid(object,x)

% determine current grid spacing average
N=numel(object.Grid);
x1=min(object.Grid);
x2=max(object.Grid);
spacing=(x2-x1)/(N-1);

% handle input
if (nargin<2) || isempty(x)  
    x=x1:spacing:x2;
else
    dx=abs(diff(x));
    ratio=dx/spacing-1;
    if any(ratio>1e-6)
       warning('WARNING: using a coarser grid may cause aliasing');
    end
end

object.Grid=x;
for n=1:object.NumberSignals
    y=interp1(object.Grid,object.Data(:,n),x,'linear');
    object.Data(:,n)=y;
end

object=updateHistory(object);

end