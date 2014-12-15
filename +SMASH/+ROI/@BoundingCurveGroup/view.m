% view Display group objects
%
% This method displays one or more BoundingCurve objects in the group.
%     >> view(object); % view all objects
%     >> view(object,[]); % view all objects
%     >> view(object,index); % view specified objects
% By default, objects are displayed in on an axis in a new figure.  Passing
% a graphic handle:
%    >> view(object,index,target);
% draws the objects on the target axes.
%
% See also BoundingCurveGroup, summarize
%

%
% created December 15, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,index,target)

% manage input
if (nargin<2) || isempty(index)
    index=1:numel(object.Children);
end

if (nargin<3) || isempty(target)
    figure;
    target=axes('Box','on');
end
assert(ishandle(target),'ERROR: invalid target axes handle');

% display children
N=numel(index);
parent=nan(1,N);
for n=1:N
    verifyIndex(object,index(n));
    parent(n)=view(object.Children{index(n)},target);
end

% manage output
if nargout>0
    varargout{1}=parent;
end

end