% characterize Determine settings from measurement
%
% This method characterizes certain settings in a PDV object from the
% meausured signal.  Characterization is performed over a rectangular
% region of time-frequency space (t1 <= t <= t2 and f1 <= f <= f2).  This
% region can be specified manually:
%     >> object=characterize(object,mode,[t1 t2]); % use all frequencies
%     >> object=characterize(object,mode,[t1 t2],[f1 f2]);
% or by interactive selection from the object's preview image.
%     >> object=characterize(object,mode);
% 
% Several characterization modes are supported.
%     -'ReferenceFrequency' determines the reference frequency, i.e. the
%     beat frequency associated with zero velocity.  The characterization
%     region should contain a single spectral peak at fixed frequency.  The
%     frequency range should be as narrow as possible.
%     -'NoiseAmplitude' determines the RMS noise of the signal.  The
%     selected region should contain noise with *no* harmonic content.  the
%     frequency range should be as wide as possible.
% Large time ranges improves characterization in all cases.
%
% See also PDV, configure
%

%
% created March 2, 2015 by Daniel Dolan (Sandia National Laboratories)
% modified May 5, 2015 by Daniel Dolan
%   -Added noise amplitude characterization
%
function object=characterize(object,mode,varargin)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(ischar(mode),'ERROR: invalid mode request');

tbound=[-inf +inf];
fbound=[-inf +inf];
Narg=numel(varargin);
if Narg==0
    preview(object);
    fig=gcf;
    ha=gca;
    hb=uicontrol('Style','pushbutton','String','Done',...
        'Callback','delete(gcbo)');
    waitfor(hb);
    tbound=xlim(ha);
    fbound=ylim(ha);
    close(fig);    
elseif Narg==1
    tbound=varargin{1};
elseif Narg==2
    tbound=varargin{1};
    fbound=varargin{2};
end

% error checking
assert(isnumeric(tbound) && (numel(tbound)==2),...
    'ERROR: invalid time range');
tbound=sort(tbound);
assert(isnumeric(fbound) && (numel(fbound)==2),...
    'ERROR: invalid frequency range');
fbound=sort(fbound);

% perform characterization
temp=object.Measurement;
temp=limit(temp,'all');
temp=crop(temp,tbound);
temp.FFToptions.FrequencyDomain='positive';
temp.FFToptions.SpectrumType='power';
temp.FFToptions.NumberFrequencies=1e6;
[f,P]=fft(temp,temp.FFToptions);
keep=(f>=fbound(1)) & (f<=fbound(2));
f=f(keep);
P=P(keep);
switch lower(mode)
    %case 'bandwidth'
    case 'noiseamplitude'        
        noisefloor=mean(P);        
        t=object.Measurement.Grid;
        keep=(t>=tbound(1)) & (t<=tbound(2));
        t=t(keep);
        s=randn(size(t));
        new=SMASH.SignalAnalysis.Signal(t,s);
        [f,P]=fft(new,temp.FFToptions);
        keep=(f>=fbound(1)) & (f<fbound(2));
        %f=f(keep);
        P=P(keep);
        correction=noisefloor/mean(P);
        object.Settings.NoiseAmplitude=sqrt(correction);
    case 'referencefrequency'
        [~,index]=max(P);
        object.Settings.ReferenceFrequency=f(index);
    otherwise
        error('ERROR: %s is an invalid mode',mode);
end

end