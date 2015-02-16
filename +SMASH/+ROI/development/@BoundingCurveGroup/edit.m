% select Edit group object
% 
% This method allows one BoundingCurve object in the group to be edited (at
% a time).
%    >> edit(object,index,[target]);
% Editing is managed by the "select" method of the BoudingCurve class; an
% optional target axes handle can be passed to this method for interactive
% boundary selection.
%
% See also BoundingCurveGroup, BoundingCurve
%

%
% created December 15, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function edit(object,index,target)

% manage input
assert(nargin>=2,'ERROR: no index specified');
verifyIndex(object,index);

if (nargin<3) || isempty(target)
    figure;
    target=axes('Box','on');
end
assert(ishandle(target),'ERROR: invalid target axes handle');

% select active child
temp=object.Children{index};
temp=select(temp,target);
object.Children{index}=temp;

end