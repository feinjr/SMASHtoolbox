% analyze Perform history analysis
%
% This method performs PDV history analysis and stores the output in the
% object's Results property.  The number of histories generated during the
% analysis depends on the number of specified boundaries; if no boundaries
% are defined, a single history with no frequency bounds is generated.
%
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
% created march 2, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=analyze(object,mode,varargin)

%% manage input
if (nargin<2) || isempty(mode)
    mode='centroid';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);

%% manage boundaries and limits
[xlimit,~]=limit(object.Measurement);
M=numel(xlimit);
xlimit=sort([xlimit(1) xlimit(end)]);
SampleTime=diff(xlimit)/(M-1);
NyquistFrequency=1/(2*SampleTime);
previous.Bound=xlimit;

boundary=object.Settings.Boundary;
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
    function out=centroid(f,y,t,~)    
        tmid=(t(end)+t(1))/2;
        out=nan(Nboundary,3);
        for k=1:Nboundary            
            [fA,fB]=probe(boundary{k},tmid);
            if isnan(fA) || isnan(fB)
                continue
            end
            index=(f>=fA)&(f<=fB);
            fb=f(index);
            w=y(index);
            out(k,3)=trapz(fb,w); % area
            w=w/out(k,3);
            out(k,1)=trapz(fb,w.*fb); % center location
            out(k,2)=trapz(fb,w.*(fb-out(k,1)).^2); % standard deviation
            out(k,2)=sqrt(out(k,2));
        end        
        out=out(:);
    end

    function out=fit(f,y,t,~)               
        tmid=(t(end)+t(1))/2;
        [fA,fB]=deal(nan(Nboundary,1));
        for k=1:Nboundary
            [fA(k),fB(k)]=probe(boundary{k},tmid);                        
        end
        out=fitComplexGaussians(f,y,fA,fB,FitOptions);
        out=out(:);
    end

previous.FFToptions=object.Measurement.FFToptions;
object.Measurement.FFToptions.FrequencyDomain='positive';
switch lower(mode)
    case 'centroid'
        object.Measurement.FFToptions.SpectrumType='power';    
        history=analyze(object.Measurement,@centroid);       
    case 'fit'        
        object.Measurement.FFToptions.SpectrumType='complex';     
        Window={'gaussian' 3};
        temp=object.Measurement.FFToptions.Window;
        if iscell(temp)
            if strcmpi(temp{1},'gaussian') || strcmpi(temp{1},'gauss')
                Window=temp;
            end
        end
        object.Measurement.FFToptions.Window=Window;
        FitOptions=struct();
        FitOptions.UniqueTolerance=object.Settings.UniqueTolerance;
        FitOptions.Tau=object.Measurement.Partition.Duration;
        FitOptions.Tau=FitOptions.Tau/(2*Window{2});
        history=analyze(object.Measurement,@fit);
    otherwise
        error('ERROR: %s is not a valid analysis mode',mode);
end

%% separate and convert results
result=struct();
index=1:numel(boundary);
result.BeatFrequency=...
    SMASH.SignalAnalysis.SignalGroup(history.Grid,history.Data(:,index));
result.BeatFrequency.GridLabel='Time';
result.BeatFrequency.DataLabel='Beat Frequency';
index=index+numel(boundary);
result.BeatWidth=...
    SMASH.SignalAnalysis.SignalGroup(history.Grid,history.Data(:,index));
result.BeatWidth.GridLabel='Time';
result.BeatWidth.DataLabel='Beat frequency width';
index=index+numel(boundary);
result.BeatAmplitude=...
    SMASH.SignalAnalysis.SignalGroup(history.Grid,history.Data(:,index));
result.BeatAmplitude.GridLabel='Time';
result.BeatAmplitude.DataLabel='Beat amplitude';
object.Results=result;

object=convert(object);

%% restore previous state
object=limit(object,previous.Bound);
object.Measurement.FFToptions=previous.FFToptions;

end