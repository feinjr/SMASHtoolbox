function verifyIndex(object,index)

assert(isnumeric(index),'ERROR: invalid index');
N=numel(object.Children);
assert(any(index==1:N),'ERROR: invalid index');

end