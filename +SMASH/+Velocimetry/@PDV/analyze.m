% UNDER CONSTRUCTION...
%
% Power spectrum tracking:
%     >> object=analyze(object,'centroid');
%     >> object=analyze(object,'fit');
%


function object=analyze(object,mode,varargin)

%% manage input
if (nargin<2) || isempty(mode)
    mode='centroid';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);

if (nargin<3) || isempty(varargin{1})
    [x,~]=limit(object.Measurement);
    points=ceil(numel(x)/1000);
    type='points';
    param=points;
else
    type=varargin{1}{1};
    param=varargin{1}{2};
end
object.Measurement=partition(object.Measurement,type,param);

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

[x,~]=limit(object.Measurement);
x=sort([x(1) x(end)]);
for n=1:Nboundary
    table=boundary{n}.Data;
    if isempty(table)
        continue
    end
    table=table(:,1);
    x(1)=min(x(1),min(table));
    x(2)=max(x(2),max(table));
end
object.Measurement=limit(object.Measurement,x);

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

    function out=powerFit(f,y,t,~)
        tmid=(t(end)+t(1))/2;
        out=nan(Nboundary,3);
        for k=1:Nboundary
            [fA,fB]=probe(boundary{k},tmid);
            index=(f>=fA)&(f<=fB);
            fb=f(index);
            w=y(index);
            % under construction
        end
        out=out(:);
    end

% DO THESE REALLY NEED TO BE DISTICT?
    function out=complexFit(f,y,t,~)
        
    end

switch lower(mode)
    case 'centroid'
        temp=object.Measurement.FFToptions.SpectrumType;
        assert(strcmpi(temp,'power'),...
            'ERROR: SpectrumType must be ''power'' for centroid tracking');
        temp=analyze(object.Measurement,@centroid);
        result=struct();
        index=1:numel(boundary);
        result.Location=...
            SMASH.SignalAnalysis.SignalGroup(temp.Grid,temp.Data(:,index));
        result.Location.GridLabel='Time';
        result.Location.DataLabel='Frequency location';
        index=index+numel(boundary);
        result.Width=...
            SMASH.SignalAnalysis.SignalGroup(temp.Grid,temp.Data(:,index));
        result.Width.GridLabel='Time';
        result.Width.DataLabel='Frequency width';
        index=index+numel(boundary);
        result.Amplitude=...
            SMASH.SignalAnalysis.SignalGroup(temp.Grid,temp.Data(:,index));
        result.Amplitude.GridLabel='Time';
        result.Amplitude.DataLabel='Magnitude';
        object.Results=result;        
    case 'fit'
        %temp=object.Measurement.FFToptions.SpectrumType;
        %if strcmpi(temp,'power')
        %    %result=analyze(object.Measurement,@powerFit);
        %elseif strcmpi(temp,'complex')
        %    %result=analyze(object.Measurement,@complexFit);
        %end
    otherwise
        error('ERROR: %s is not a valid track mode',mode);
end

%% frequency to velocity conversion
lambda=object.Settings.Wavelength;
f0=object.Settings.ReferenceFrequency;
    function velocity=standardConvert(~,frequency)
        velocity=(lambda/2)*(frequency-f0);
    end

location=object.Results.Location;
if isempty(object.Settings.ConvertFunction)
    v=standardConvert(location.Grid,location.Data);    
else
   v=feval(object.Settings.ConvertFunction,location.Grid,location.Data);
end
object.Results.Velocity=SMASH.SignalAnalysis.SignalGroup(location.Grid,v);
object.Results.Velocity.GridLabel='Time';
object.Results.Velocity.DataLabel='Velocity';

%% uncertainty analysis

end
