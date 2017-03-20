% characterize Characterize measurement region.
%
% This method characterizes a time-frequency region in a PDV measurement.
%    object=characterize(object,mode);
% Several characterization modes are supported:
%    -'reference' determines the reference frequency.
%    -'noise' determines the noise amplitude (and spectrum)
% By default, the characterization time and frequency range are selected
% interactively.  
%    objct=characterize(object,'reference');
%    object=characterize(object,'noise');
% Characterization time and frequency ranges can also be specified
% directly.
%    object=characterize(object,mode,'time',[t1 t2]); % use all frequencies
%    object=characterize(object,mode,'frequency',[f1 f2]); % use all times
%    object=characterize(object,mode,'time',[t1 t2],'frequency',[f1 f2]); 
%
% See also PDV, analyze
%

%
% revised Feburary 7, 2017 by Daniel Dolan (Sandia National Laboratory)
% updated March 14, 2017 by Daniel Dolan
%   -clarified documentation
%
function object=characterize(object,mode,varargin)

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
    if isempty(object.Preview);
        warning('SMASH:PDV','Generating preview image because none was found');
        object=preview(object);
    end
    preview(object);
    fig=gcf;
    ha=gca;
    hb=uicontrol('Style','pushbutton','String','Done');
    set(hb,'Callback',@(~,~) delete(hb));
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
fNyquist=f(end);
    function G=transfer(f)
        G=interp1(fk,Pk,abs(f),'linear');
    end

keep=(f>=option.Frequency(1)) & (f<=option.Frequency(2));
fk=f(keep);
Pk=P(keep);
area1=trapz(fk,Pk);

t=selection.Measurement.Grid;
T=abs(t(end)-t(1))/(numel(t)-1);
fNyquist=1/(2*T);

% perform characterization
switch mode    
    case 'noise'
        if fk(1) > 0
            fk(2:end+1)=fk;
            fk(1)=0;
            Pk(2:end+1)=Pk;
            Pk(1)=0;
        end
        if fk(end) < fNyquist
            fk(end+1)=fNyquist;
            Pk(end+1)=0;
        end     
        object.NoiseSignal.Amplitude=1;
        object.NoiseSignal=defineGrid(object.NoiseSignal,selection.Measurement.Grid);
        object.NoiseSignal=defineTransfer(object.NoiseSignal,'function',@transfer);
        object.NoiseSignal=generate(object.NoiseSignal);
        [f,P]=fft(object.NoiseSignal.Measurement,selection.FFToptions);
        keep=(f>=option.Frequency(1)) & (f<option.Frequency(2));
        area2=trapz(f(keep),P(keep));
        object.NoiseSignal.Amplitude=sqrt(area1/area2);      
        object.NoiseCharacterized=true;
        object.NoiseDefined=true;
    case 'reference'
        index=(P >= (0.50*max(P)));
        f=f(index);
        P=P(index);
        object.ReferenceFrequency=trapz(f,f.*P)/trapz(f,P);
end

end