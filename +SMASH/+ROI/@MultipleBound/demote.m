function object=demote(object,index)

% handle input
assert(nargin>=2,'ERROR: no index specified');
verifyIndex(object,index);

% move requested object
N=numel(object.BoundArray);
if index<N
    temp=object.BoundArray{index+1};
    object.BoundArray{index+1}=object.BoundArray{index};
    object.BoundArray{index}=temp;
end

end