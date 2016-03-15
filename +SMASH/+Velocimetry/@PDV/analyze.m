% analyze Perform history analysis
%
% object=analyze(object,'power');
% object=analyze(object,'power',mode); % 'centroid'
%
% object=analyze(object,'sinusoid');
% object=analyze(object,'sinusoid',name,value,...)
% Valid names:
%   'UniqueTolerance'
%   'ElectricalHarmonics' 
%   'OpticalHarmonics'
%
% 

% This method performs PDV history analysis...
%and stores the output in the
% object's Results property.  The number of histories generated during the
% analysis depends on the number of specified boundaries; if no boundaries
% are defined, a single history with no frequency bounds is generated.



% OLD SYNTAX
% The default analysis calculates centroids for each boundary region.
%     >> object=analyze(object);
%     >> object=analyze(object,'centroid'); % same as above
% Complex spectral fit analysis can also be requested.
%     >> object=analyze(object,'fit');
% Details of the latter approach are currently being revised
%
% See also PDV, bound, configure, convert, partition
%

%
% Created March 2, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=analyze(object,AnalysisMode,varargin)

%% manage input
if (nargin<2) || isempty(AnalysisMode)
    AnalysisMode='power';
end
assert(ischar(AnalysisMode),'ERROR: invalid analysis mode');

%% verify partition settings
if isempty(object.Measurement.Partition)
    message{1}='ERROR: analysis partitions are undefined';
    message{2}='       Use the "configure" method to define partitions';
    error('%s\n',message{:});
end

%% manage boundaries and limits
[xlimit,~]=limit(object.Measurement);
M=numel(xlimit);
xlimit=sort([xlimit(1) xlimit(end)]);
SampleTime=diff(xlimit)/(M-1);
NyquistFrequency=1/(2*SampleTime);

boundary=object.Boundary;
if isempty(boundary)
    table=nan(2,3);    
    table(1,:)=[xlimit(1) NyquistFrequency/2 NyquistFrequency/2];
    table(2,:)=[xlimit(2) NyquistFrequency/2 NyquistFrequency/2];
    boundary=SMASH.ROI.BoundingCurve('horizontal',table);
    boundary.Label='Default boundary';
    boundary={boundary};
end
Nboundary=numel(boundary);

xbound=[+inf -inf];
for n=1:Nboundary
    table=boundary{n}.Data;
    if isempty(table)
        continue
    end
    table=table(:,1);
    table=[min(table) max(table)];
    xbound(1)=min(xbound(1),table(1));
    xbound(2)=max(xbound(2),table(2));
end
xbound(1)=max(xbound(1),xlimit(1));
xbound(2)=min(xbound(2),xlimit(2));
measurement=limit(object.Measurement,xbound);

%% perform analysis
setting=object.Settings;
setting.SampleRate=object.SampleRate;
setting.DomainScaling=object.DomainScaling;
setting.BoxcarDuration=object.BoxcarDuration;
setting.RMSnoise=object.Settings.RMSnoise;
switch lower(AnalysisMode)
    case 'power'        
        history=analyzeSpectrum(measurement,boundary,...
            setting,varargin{:});                
    case 'sinusoid'
        history=analyzeSinusoid(measurement,boundary,...
            settings,varargin{:});
    otherwise
        error('ERROR: %s is not a valid analysis mode',AnalysisMode);
end

%% separate and process results
N=numel(boundary);
object.Frequency=cell(1,N);
object.Velocity=cell(1,N);
index=1:4; % center, uncertainty, chirp, unique
for m=1:N
    % remove NaN entries
    t=history.Grid;
    data=history.Data(:,index);
    keep=~isnan(data(:,1));
    t=t(keep);
    data=data(keep,:);
    % store new object
    object.Frequency{m}=SMASH.SignalAnalysis.SignalGroup(t,data);    
    object.Frequency{m}.GridLabel='Time';
    object.Frequency{m}.DataLabel='';
    object.Frequency{m}.Legend={'Center' 'Uncertainty' 'Chirp','Unique'}; 
    % transfer label
    try
        object.Frequency{m}.Name=object.Boundary{m}.Label;
    catch
        object.Frequency{m}.Name='(no name)';
    end
    index=index+numel(index);
end

end