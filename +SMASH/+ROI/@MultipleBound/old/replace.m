function object=replace(object,index,region)

% handle input
assert(nargin==3,'ERROR: no index specified');
verifyIndex(object,index);

% replace bound
test=strcmp(...
    class(object.BoundArray{index}),class(region));
assert(test,'ERROR: incompatible region type');
object.BoundArray{index}=region;

end