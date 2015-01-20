function object=create(object,varargin)

object.Name='SignalGroup object';

Narg=numel(varargin);
assert(Narg==2,'ERROR: invalid number of inputs');
assert(isnumeric(varargin{1}) && isnumeric(varargin{2}),...
    'ERROR: invalid input');

object.Data=varargin{2};
numpoints=size(object.Data,1);
object.NumberSignals=size(object.Data,2);

object.Grid=varargin{1}(:);
if isempty(object.Grid)
    object.Grid=transpose(1:numpoints);
elseif numel(object.Grid)==1
    object.Grid=repmat(object.Grid,[size(object.Data,1) 1]);
    object.Grid(1)=0;
    object.Grid=cumsum(object.Grid);
end

if numel(object.Grid)==size(object.Data,1)
    % do nothing
elseif numel(object.Grid)==size(object.Data,2)
    object.Data=transpose(object.Data);
    fprintf('Transposing Data array for consistency with Grid array\n');
else
    error('ERROR: incompatible Grid/Data arrays') 
end


%assert(numel(object.Grid)==size(object.Data,1),...
%    'ERROR: incompatible Grid/Data arrays')                               

label=cell(1,object.NumberSignals);
for k=1:object.NumberSignals
    label{k}=sprintf('signal %d',k);
end
object.Legend=label;


            