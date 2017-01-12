function object=select(object,target,varargin)

if (nargin<2) || isempty(target)
    target=gca;
end
assert(ishandle(target(1)),'ERROR: invalid target axes');
if numel(target)>1
    SourceFigure=target(2);
    target=target(1);
else
    SourceFigure=[];
end
fig=ancestor(target,'figure');

end