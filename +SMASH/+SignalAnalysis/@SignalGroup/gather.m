% GATHER Combine objects into a SignalGroup
%
% This method combines SignalGroup (and Signal) objects into a new object
% with a common Grid.
%    >> new=gather(object1,object2,...)
%
% See also SignalGroup, split
%

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=gather(varargin)

temp={};
label={};
for n=1:nargin
    assert(isa(varargin{n},'SMASH.SignalAnalysis.Signal'),...
        'ERROR: non-gatherable object detected')
    source=varargin{n};
    for m=1:size(source.Data,2)
        temp{end+1}=SMASH.SignalAnalysis.Signal(...
            source.Grid,source.Data(:,m)); %#ok<AGROW>                
        switch class(source)
            case 'SMASH.SignalAnalysis.Signal'
                label{end+1}=source.Name; %#ok<AGROW>
            case 'SMASH.SignalAnalysis.SignalGroup'
                label{end+1}=source.Legend{m}; %#ok<AGROW>
        end
    end
end

N=numel(temp);
[temp{:}]=register(temp{:});

Data=nan(numel(temp{1}.Data),N);
for n=1:N
    Data(:,n)=temp{n}.Data;
end
object=SMASH.SignalAnalysis.SignalGroup(temp{1}.Grid,Data);
object.Source='Signal merge';
object.GridLabel=varargin{1}.GridLabel;
object.DataLabel=varargin{1}.DataLabel;
object.NumberSignals=size(object.Data,2);
object.Legend=label;

end