% UNDER CONSTRUCTION...
%

%     >> object=analyze(object);
%     >> object=analyze(object,'centroid');

%     >> object=analyze(object,'fit');
%


function object=analyze(object,mode)

%% manage input
if (nargin<2) || isempty(mode)
    mode='centroid';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);

%% manage boundaries
boundary=object.Settings.Boundary;
if isempty(boundary)
    table=nan(2,3);    
    x=object.Measurement.Grid;
    x=sort([x(1) x(end)]);
    table(1,:)=[x(1) 0 inf];
    table(2,:)=[x(2) 0 inf];
    boundary=SMASH.ROI.BoundingCurve('horizontal',table);
    boundary.Label='Default boundary';
    boundary={boundary};
end
Nboundary=numel(boundary);

%% revise limits to match boundaries
previous.LimitIndex=object.Measurement.LimitIndex;
[xb,~]=limit(object.Measurement);
xb=sort([xb(1) xb(end)]);
for n=1:Nboundary
    table=boundary{n}.Data;
    if isempty(table)
        continue
    end
    table=table(:,1);
    xb(1)=min(xb(1),min(table));
    xb(2)=max(xb(2),max(table));
end
object.Measurement=limit(object.Measurement,xb);


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

FitOptions=struct('UniqueTolerance',object.Settings.UniqueTolerance);
% determine tau?
    function out=fit(f,y,t,~)               
        tmid=(t(end)+t(1))/2;
        [lower,upper]=deal(nan(Nboundary,1));
        for k=1:Nboundary
            [lower(k),upper(k)]=probe(boundary{k},tmid);                        
        end
        out=fitComplexGaussians(f,y,lower,upper,FitOptions);
        out=out(:);
    end

previous.FFToptions=object.Measurement.FFToptions;
switch lower(mode)
    case 'centroid'
        object.Measurement.FFToptions.SpectrumType='power';    
        history=analyze(object.Measurement,@centroid);       
    case 'fit'
        
        object.Measurement.FFToptions.SpectrumType='complex';        
        history=analyze(object.Measurement,@fit);
    otherwise
        error('ERROR: %s is not a valid analysis mode',mode);
end

%% separate and convert results
result=struct();
index=1:numel(boundary);
result.Location=...
    SMASH.SignalAnalysis.SignalGroup(history.Grid,history.Data(:,index));
result.Location.GridLabel='Time';
result.Location.DataLabel='Frequency location';
index=index+numel(boundary);
result.Width=...
    SMASH.SignalAnalysis.SignalGroup(history.Grid,history.Data(:,index));
result.Width.GridLabel='Time';
result.Width.DataLabel='Frequency width';
index=index+numel(boundary);
result.Amplitude=...
    SMASH.SignalAnalysis.SignalGroup(history.Grid,history.Data(:,index));
result.Amplitude.GridLabel='Time';
result.Amplitude.DataLabel='Power';
object.Results=result;

object=convert(object);

%% restore previous state
object.Measurement.LimitIndex=previous.LimitIndex;
object.Measurement.FFToptions=previous.FFToptions;

end
