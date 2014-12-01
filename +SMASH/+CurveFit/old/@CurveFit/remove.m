% remove basis
function object=remove(object,index)

% handle input
assert(nargin==2,'ERROR: insufficient input');
if strcmpi(index,'all')
    object.BasisFunction={};
    object.Scalable=[];
    object.Guess=[];
    object.LowerBound=[];
    object.UpperBound=[];
    object.BasisIndex=[];
    return
end

assert(isnumeric(index) & (numel(index)>0),'ERROR: invalid index');
index=sort(index);
while numel(index)>0
    current=index(1);
    Nbasis=numel(object.BasisFunction);
    k=[1:(current-1) (current+1):Nbasis];
    object.BasisFunction=object.BasisFunction(k);
    object.Scalable=object.Scalable(k);
    keep=(object.BasisIndex~=current);
    object.Guess=object.Guess(keep);
    object.LowerBound=object.LowerBound(keep);
    object.UpperBound=object.UpperBound(keep);
    object.BasisIndex=object.BasisIndex(keep);
    k=(object.BasisIndex>current);
    object.BasisIndex(k)=object.BasisIndex(k)-1;
    index=index(2:end);
    index=index-1;
end

object=reset(object);

end