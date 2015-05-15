% analyze Perform history analysis
%
% This method performs PDV history analysis and stores the output in the
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
function object=analyze(object)

%% verify partition settings
if isempty(object.Measurement.Partition)
    message{1}='ERROR: analysis partitions are undefined';
    message{2}='       Use the "configure" method before "analyze"';
    error('%s\n',message{:});
end

%% manage boundaries and limits
[xlimit,~]=limit(object.Measurement);
M=numel(xlimit);
xlimit=sort([xlimit(1) xlimit(end)]);
SampleTime=diff(xlimit)/(M-1);
NyquistFrequency=1/(2*SampleTime);
previous.Bound=xlimit;

boundary=object.Boundary;
if isempty(boundary)
    table=nan(2,3);    
    table(1,:)=[xlimit(1) 0 NyquistFrequency];
    table(2,:)=[xlimit(2) 0 NyquistFrequency];
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
object.Measurement=limit(object.Measurement,xbound);

%% perform analysis    
%previous.FFToptions=object.Measurement.FFToptions;
switch lower(object.Settings.AnalysisMode)
    case 'centroid'
        object.Measurement.FFToptions.SpectrumType='power';
        history=analyze(object.Measurement,...
            @(f,y,t,s) CentroidAnalysis(f,y,t,s,boundary));       
    case 'fit'           
        object.Measurement.FFToptions.SpectrumType='complex';
        Window={'gaussian' 3};
        object.Measurement.FFToptions.Window=Window;
        options=struct();
        options.UniqueTolerance=object.Settings.UniqueTolerance;
        options.Tau=object.Measurement.Partition.Duration;
        options.Tau=options.Tau/(2*Window{2});
        history=analyze(object.Measurement,...
            @(f,y,t,s) FitAnalysis(f,y,t,s,boundary,options)); 
    otherwise
        error('ERROR: %s is not a valid analysis mode',mode);
end

%% separate results
N=numel(boundary);
object.BeatFrequency=cell(1,N);
index=1:4;
for m=1:N
    % remove NaN entries
    t=history.Grid;
    data=history.Data(:,index);
    keep=~isnan(data(:,1));
    t=t(keep);
    data=data(keep,:);
    % store new object
    object.BeatFrequency{m}=SMASH.SignalAnalysis.SignalGroup(t,data);    
    object.BeatFrequency{m}.GridLabel='Time';
    object.BeatFrequency{m}.DataLabel='';
    object.BeatFrequency{m}.Legend={'Position','Width','Amplitude','Uncertainty'};    
    object.BeatFrequency{m}.Name=object.Boundary{m}.Label;
    index=index+numel(index);
end

%% complete uncertainty analysis


%% convert frequency to velocity
object=convert(object);

%% restore previous settings
object=limit(object,previous.Bound);
%object.Measurement.FFToptions=previous.FFToptions;

end