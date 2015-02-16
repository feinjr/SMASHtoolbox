% activate 
function object=activate(object,active)

% manage input
if (nargin<2) || isempty(active)
    active=object.Active;
end
valid=1:numel(object.Children);
assert(any(active==valid),'ERROR: invalid child index');

% activate selected child
object.Active=active;

end