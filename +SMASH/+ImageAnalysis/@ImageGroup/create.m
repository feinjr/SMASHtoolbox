function object=create(object,varargin)

object.Name='ImageGroup object';
object.GraphicOptions=SMASH.General.GraphicOptions;
set(object.GraphicOptions,'Title','ImageGroup object');
set(object.GraphicOptions,'YDir','reverse');

Narg=numel(varargin);
assert(Narg==3,'ERROR: invalid number of inputs');
assert(isnumeric(varargin{1}) & isnumeric(varargin{2}) & isnumeric(varargin{3}), ...
    'ERROR: invalid input');
assert(isreal(varargin{1}) & isreal(varargin{2}) & isreal(varargin{3}), ...
    'ERROR: complex numbers are not supported');

object.Data=varargin{3};
[N,M,L]=size(object.Data);
object.NumberImages=L;

object.Grid1=transpose(varargin{1}(:));
if isempty(object.Grid1)
    object.Grid1=1:M;
elseif numel(object.Grid1)==1
    object.Grid1=repmat(object.Grid1,[1 M]);
    object.Grid1(1)=0;
    object.Grid1=cumsum(object.Grid1);
end
assert(numel(object.Grid1)==M,...
    'ERROR: incompatible Grid1/Data arrays');

object.Grid2=varargin{2}(:);
if isempty(object.Grid2)
    object.Grid2=transpose(1:N);
elseif numel(object.Grid2)==1
    object.Grid2=repmat(object.Grid2,[N 1]);
    object.Grid2(1)=0;
    object.Grid2=cumsum(object.Grid2);
end
assert(numel(object.Grid2)==N,...
    'ERROR: incompatible Grid2/Data arrays');

end