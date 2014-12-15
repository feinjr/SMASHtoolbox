% promote Promote objects within a group
% 
% This method promotes one or more BoundingCurve objects in the group.
%     >> promote(object,index);
% Promoted objects are shifted towards the beginning of the group,
% alterning the overall group order.
%
% See also BoundingCurveGroup, demote
%

%
% created December 15, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function promote(object,index)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

% handle multiple indices
assert(isnumeric(index),'ERROR: invalid index');
N=numel(index);
if N>1
    for n=1:N
        promote(object,index(1));
        index=index(2:end);
        index=index-1;
    end
    return
end

% single index demotion
verifyIndex(object,index);
if index > 1
    temp=object.Children{index-1};
    object.Children{index-1}=object.Children{index};
    object.Children{index}=temp;
end

end