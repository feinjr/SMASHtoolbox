function object=remove(object,index)

% handle input
assert(nargin>=2,'ERROR: no index specified');

% remove all
if strcmp(index,'all')
    for k=1:numel(object.BoundArray)
        object=remove(object,1);
    end
    return
end

% multiple index remove
assert(isnumeric(index),'ERROR: invalid index')
N=numel(index);
if N>1
    index=sort(index);
    for n=1:N
        object=remove(object,index(1));
        index=index(2:end);
        index=index-1;
    end
    return
end

% single index remove
verifyIndex(object,index);
N=numel(object.BoundArray);
keep=[1:(index-1) (index+1):N];
object.BoundArray=object.BoundArray(keep);

end