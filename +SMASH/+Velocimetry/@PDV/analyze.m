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

%% manage boundaries and limits
[xb,~]=limit(object.Measurement);
xb=sort([xb(1) xb(end)]);
previous.Bound=xb;

boundary=object.Settings.Boundary;
if isempty(boundary)
    table=nan(2,3);    
    table(1,:)=[xb(1) 0 inf];
    table(2,:)=[xb(2) 0 inf];
    boundary=SMASH.ROI.BoundingCurve('horizontal',table);
    boundary.Label='Default boundary';
    boundary={boundary};
end
Nboundary=numel(boundary);

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
object=limit(object,previous.Bound);
object.Measurement.FFToptions=previous.FFToptions;

end
