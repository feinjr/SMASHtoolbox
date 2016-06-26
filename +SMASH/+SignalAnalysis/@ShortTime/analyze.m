% ANALYZE Perform local analysis
%
% This method applies a target function to local regions in a ShortTime
% object.
%    result=analyze(object,target);
% The target function should be passed as a function handle.  Inline
% functions can be used:
%    target=@(x,y) mean(y); % local mean
%    target=@(x,y) sqrt(mean(y.^2)); % local RMS
% Function files, such as target=@myfunction, can also be used so long as
% the function accepts two inputs and returns at least one output
% (additional outputs are ignored).  The inputs are column arrays whose
% length matching object's the "points" parameter; function's output can be
% a scalar or one-dimenional array.  The method's
% output "result" is a SignalGroup object, with function evaluations stored
% in the Data property and regional time centers stored in the Grid
% property.
%
% This method automatically performs parallel processing when available.
% If multiple MATLAB workers are present, regional evaluations are managed
% with a parallelized "parfor" loop; otherwise, a standard "for" loop is
% used.  Due to differences in how these loops may be evaluated, the target
% function should *not* rely on evaluation order!
%
% See also SMASH.SignalAnalysis.ShortTime, partition
%

%
% created April 8, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=analyze(object,target_function)

% handle input
if (nargin<2) || isempty(target_function)
    target_function=@(x,y) y;
end
%assert(nargin==2,'ERROR: no target function specified');
if ischar(target_function)
    target_function=str2func(target_function);
end
if ~isa(target_function,'function_handle')
    error('ERROR: invalid target function');
end

% analyze region of interest
[time,signal]=limit(object.Measurement);
numpoints=numel(time);

points=object.Partition.Points;
skip=object.Partition.Skip;

right=points:skip:numpoints;
left=right-points+1;
center=(time(left)+time(right))/2;
Niter=numel(center);

% analyze the first block
try
    temp=analyzeBlock(time,signal,left(1):right(1),target_function);
catch exception
    message{2}='* Target function error *';
    message{3}=repmat('*',size(message{2}));
    message{1}=message{3};
    fprintf('%s\n',message{:});
    throw(exception)
end
data=nan(numel(temp),Niter);
data(:,1)=temp(:);

% analyze remaining blocks  
if SMASH.System.isParallel
    fprintf('Performing analysis...');
    parfor k=2:Niter
        temp=analyzeBlock(time,signal,left(k):right(k),target_function);        
        data(:,k)=temp(:);
    end
    fprintf('done!\n');
else
    fprintf('Performing analysis...');
    for k=2:Niter
        temp=analyzeBlock(time,signal,left(k):right(k),target_function);        
        data(:,k)=temp(:);
    end
    fprintf('done!\n');
end

% handle output
data=transpose(data);

result=SMASH.SignalAnalysis.SignalGroup(center,data);
result.GridLabel=object.Measurement.GridLabel;
result.DataLabel='Result';
label=cell(result.NumberSignals,1);
for n=1:result.NumberSignals
    label{n}=sprintf('Result %d',n);
end
result.Legend=label;

if nargout==0
    view(result);
else
    varargout{1}=result;
end

end

function out=analyzeBlock(time,signal,index,LocalFunction)

time=time(index);
signal=signal(index);

out=LocalFunction(time,signal);

end