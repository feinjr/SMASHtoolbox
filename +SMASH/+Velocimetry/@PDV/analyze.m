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
function object=analyze(object,SpectrumType,varargin)

%% manage input
if (nargin<2) || isempty(SpectrumType)
    SpectrumType='power';
end
assert(ischar(SpectrumType),'ERROR: invalid analysis mode');

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
options=struct();
options.ScaleFactor=Spectrum2SignalScale(object.Measurement);
switch lower(SpectrumType)
    case 'power'
        object.Measurement.FFToptions.SpectrumType='power';        
        if isempty(varargin) || strcmpi(varargin{1},'centroid')
            TargetFunction=@(f,y,t,s) PowerAnalysisCentroid(...
                f,y,t,s,boundary,options);
        else
            error('ERROR: alternate power modes not supported yet');
        end
    case 'fit'           
        object.Measurement.FFToptions.SpectrumType='complex';
        Window={'gaussian' 3};
        object.Measurement.FFToptions.Window=Window;
        options.UniqueTolerance=object.Settings.UniqueTolerance;
        options.Tau=object.Measurement.Partition.Duration;
        options.Tau=options.Tau/(2*Window{2});
        TargetFunction= @(f,y,t,s) ComplexAnalysis(f,y,t,s,boundary,options);
    otherwise
        error('ERROR: %s is not a valid analysis mode',mode);
end
history=analyze(object.Measurement,TargetFunction,'none');

%% separate and process results
N=numel(boundary);
index=1:4; % location, strength, unique, chirp
for m=1:N
    % remove NaN entries
    t=history.Grid;
    data=history.Data(:,index);
    keep=~isnan(data(:,1));
    t=t(keep);
    data=data(keep,:);
    % store new object
    object.Results{m}=SMASH.SignalAnalysis.SignalGroup(t,data);    
    object.Results{m}.GridLabel='Time';
    object.Results{m}.DataLabel='';
    object.Results{m}.Legend={'Center','Width','Strength','Unique'}; 
    % transfer label
    try
        object.Results{m}.Name=object.Boundary{m}.Label;
    catch
        object.Results{m}.Name='(no name)';
    end
    index=index+numel(index);
end

%% restore previous settings
object=limit(object,previous.Bound);

end