function object=create(object,varargin)

object.Name='SignalGroup object';

Narg=numel(varargin);
assert(Narg>0,'ERROR: insufficient input');

% manage object input
if isa(varargin{1},'SMASH.SignalAnalysis.Signal')
    if isa(varargin{1},'SMASH.SignalAnalysis.SignalGroup')
        object=varargin{1};
    else
        object=SMASH.SignalAnalysis.SignalGroup...
            (varargin{1}.Grid,varargin{1}.Data);
    end
    if Narg>1
        object=gather(object,varargin{2:end});
    end    
    return
end

% manage numeric input
assert(Narg==2,'ERROR: invalid number of inputs');
assert(isnumeric(varargin{1}) && isnumeric(varargin{2}),...
    'ERROR: invalid input');

object.Grid=varargin{1};
object.Data=varargin{2};
if isempty(object.Grid)
    object.Grid=1:size(object.Data,1);
elseif numel(object.Grid)==1
    object.Grid=repmat(object.Grid,[size(object.Data,1) 1]);
    object.Grid(1)=0;
    object.Grid=cumsum(object.Grid);
elseif numel(object.Grid)==size(object.Data,1)
    % do nothing
elseif numel(object.Grid)==size(object.Data,2)
    object.Data=transpose(object.Data);
    fprintf('Transposing Data array for consistency with Grid array\n');
else
    error('ERROR: incompatible Grid/Data arrays')
end
object.Grid=object.Grid(:);
object.NumberSignals=size(object.Data,2);

label=cell(1,object.NumberSignals);
for k=1:object.NumberSignals
    label{k}=sprintf('signal %d',k);
end
object.Legend=label;