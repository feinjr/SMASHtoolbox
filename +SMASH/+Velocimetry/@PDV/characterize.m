% characterize Characterize measurement region.
%
% This method characterizes a time-frequency region in a PDV measurement.
% Several characterization modes are supported:
%    -'reference' determines the reference frequency, i.e. the
%     beat frequency associated with zero velocity. 
%    -'noise' determines the RMS noise of the signal.
%
% Characterization is performed over a manually specified or interactively
% selected region.
%    result=characterize(object,mode,...);
% Name/value pairs specified after the mode control the time and frequency
% bounds of the characterization region.  Several examples are shown below.
%    f0=characterize(object,'reference'); % interactive selection
%    f0=characterize(object,'reference','time',[t1 t2]); % use all frequencies
%    f0=characterize(object,'reference','frequency',[f1 f2]); % use all times
%    f0=characterize(object,'reference','time',[t1 t2],'frequency',[f1 f2]); 
%
% See also PDV
%

%
% revised Feburary 7, 2017 by Daniel Dolan (Sandia National Laboratory)
%
function result=characterize(object,mode,varargin)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(ischar(mode),'ERROR: invalid mode request');
mode=lower(mode);
switch mode
    case {'reference' 'noise'}
        % valid modes
    otherwise
        error('ERROR: invalid characterization mode');
end

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

option.Time=[];
option.Frequency=[];
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'time'
            assert(isnumeric(value) && numel(value)==2,...
                'ERROR: invalid time bound');
            option.Time=sort(value);
        case 'frequency'
            assert(isnumeric(value) && numel(value)==2,...
                'ERROR: invalid frequency bound');
            option.Frequency=sort(value);            
        otherwise
            error('ERROR: invalid option name');
    end
end

if isempty(option.Time) && isempty(option.Frequency)
    assert(~isempty(object.Preview),...
        'ERROR: interactive region selection cannot be performed without a preview image');
    preview(object);
    fig=gcf;
    ha=gca;
    hb=uicontrol('Style','pushbutton','String','Done',...
        'Callback','delete(gcbo)');
    warning off %#ok<WNOFF>
    switch mode
        case 'reference'
            label='Select reference region';
        case 'noise'
            label='Select noise region';
    end
    title(label);
    warning on %#ok<WNON>
    set(gcf,'Name','Select region','NumberTitle','off');
    waitfor(hb);
    option.Time=xlim(ha);
    option.Frequency=ylim(ha);
    close(fig);
elseif isempty(option.Time)
    option.Time=[-inf +inf];
elseif isempty(option.Frequency)
    option.Frequency=[-inf +inf];
end

% process selected region
selection=object.STFT;
selection.Measurement=limit(selection.Measurement,'all');
selection.Measurement=crop(selection.Measurement,option.Time);

selection.FFToptions.FrequencyDomain='positive';
selection.FFToptions.SpectrumType='power';
[f,P]=fft(selection.Measurement,selection.FFToptions);

keep=(f>=option.Frequency(1)) & (f<=option.Frequency(2));
f=f(keep);
P=P(keep);

t=selection.Measurement.Grid;
T=abs(t(end)-t(1))/(numel(t)-1);
fNyquist=1/(2*T);

% perform characterization
switch mode    
    case 'noise'        
        noisefloor=mean(P);
        % simulate noise
        noise=SMASH.SignalAnalysis.NoiseSignal(selection.Measurement.Grid); 
        if isempty(object.Bandwidth)
            bandwidth=fNyquist/2;
            warning('PDV:characterize',...
                'Assuming bandwidth is half of the Nyquist frequency');
        else
            bandwidth=object.Bandwidth;
        end  
        noise=defineTransfer(noise,'bandwidth',bandwidth);
        noise=generate(noise);                
        [f,P]=fft(noise.Measurement,selection.FFToptions);
        keep=(f>=option.Frequency(1)) & (f<option.Frequency(2));
        P=P(keep);
        correction=noisefloor/mean(P);
        result=sqrt(correction);
    case 'reference'
        [~,index]=max(P);
        result=f(index);   
end

end