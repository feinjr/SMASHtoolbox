function object=create(object,varargin)

Narg=numel(varargin);
assert(Narg==2,'ERROR: invalid number of inputs');
assert(isnumeric(varargin{1}) && isnumeric(varargin{2}),...
    'ERROR: invalid input');

object.Data=varargin{2}(:);
numpoints=numel(object.Data); 

object.Grid=varargin{1}(:);
if isempty(object.Grid)
    object.Grid=transpose(1:numpoints);
elseif numel(object.Grid)==1
    object.Grid=repmat(object.Grid,size(object.Data));
    object.Grid(1)=0;
    object.Grid=cumsum(object.Grid);
end
assert(numel(object.Grid)==numel(object.Data),...
    'ERROR: incompatible Grid/Data arrays');

object.Name='Signal object';

object.PlotOptions=set(object.PlotOptions,...
    'Marker','none','LineStyle','-');