% verifyGrid validate Signal grid and check direction/uniformity
%
% This method verifies that the Grid array increases or decreases
% monotonically.  Increasing grids are labelled with a GridDirection of
% "normal", while decreasing grids are labelled as "reverse".  The average
% grid spacing is also determined; if the actual grid varies less than 0.1%
% from this uniform case, GridUniform is set to true.
%

function object=verifyGrid(object)

% determine direction and mean spacing
x=object.Grid;
dxmean=x(end)-x(1);
if dxmean>0
    object.GridDirection='normal';    
else
    object.GridDirection='reverse';    
end
dxmean=dxmean/(numel(x)-1);
object.GridSpacing=dxmean;

% look for repeated grid points (usually a round off issue)
dx=diff(x);
%if any(dx==0 | sign(dx)~=sign(dxmean))
if any(dx==0)
    warning('WARNING: repeated Grid values detected, using "Unique"');
    [~,index] = unique(x);
    object.Grid = object.Grid(index);
    object.Data = object.Data(index);
    object=verifyGrid(object);
    return
end

% check for monotonic increase/decrease
assert(all(sign(dx)==sign(dxmean)),...
    'ERROR: non-monotonic Grid detected');

% check uniformity
xu=x(1):dxmean:x(end);
xu=reshape(xu,size(x));
delta=abs((x-xu)/dxmean);
if any(delta>1e-3)
    object.GridUniform=false;
else
    object.GridUniform=true;
end

end