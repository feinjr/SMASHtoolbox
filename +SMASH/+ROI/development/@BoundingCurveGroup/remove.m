% remove Remove object(s) from the group
%
% This method removes one or more BoundingCurve objects from the group.
% Objects for removal can be specified by numerical index:
%     >> remove(group,index);
% or all at once.
%     >> remove(group,'all');
%
% See also BoundingCurveGroup, add
%

%
% created December 15, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function remove(object,index)

% manage input
assert(nargin>=2,'ERROR: no index specified');

% remove all
if strcmp(index,'all')
    index=1:numel(object.Children);
    remove(object,index);
    return
end

% multiple index remove
assert(isnumeric(index),'ERROR: invalid index')
N=numel(index);
if N>1
    index=sort(index);
    for n=1:N
        remove(object,index(1));
        index=index(2:end);
        index=index-1;
    end
    return
end

% single index remove
verifyIndex(object,index);
N=numel(object.Children);
keep=[1:(index-1) (index+1):N];
object.Children=object.Children(keep);

end