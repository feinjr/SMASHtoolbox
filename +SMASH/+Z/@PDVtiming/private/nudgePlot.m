% nudge a plot upward to leave room for buttons underneath
function nudgePlot(haxes,hbutton,margin)

% manage input
assert(nargin>=2,'ERROR: insufficent input');

if (nargin<3) || isempty(margin)
    margin=5;
end
assert(isnumeric(margin) && isscalar(margin),'ERROR: invalid margin');

% determine vertical boundary
yb=0;
for n=1:numel(hbutton)
    old=get(hbutton(n),'Units');
    set(hbutton(n),'Units','pixels');
    position=get(hbutton(n),'Position');
    yb=min(yb,position(2)+position(4));
    set(hbutton(n),'Units',old);
end

end