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
function promote(object,index,full)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

if (nargin<3) || isempty(full)
    full=false;
elseif strcmpi(full,'full')
    full=true;
else
    full=false;
end

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

% single index promotion
verifyIndex(object,index);
if index > 1
    if full
        new=1;
    else
        new=index-1;
    end
    temp=object.Children{new};
    object.Children{new}=object.Children{index};
    object.Children{index}=temp;
end

end