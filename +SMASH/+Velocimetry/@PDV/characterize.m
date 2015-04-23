% characterize Determine settings from measurement
%
% This method determines certain settings in a PDV object from the
% meausured signal.  User guidance is an important part of the process.
%
% To determine the reference frequency:
%     >> object=characterize(object,'ReferenceFrequency',[t1 t2]);
%     >> object=characterize(object,'ReferenceFrequency',[t1 t2],[f1 f2]);
% Both expressions use a power spectrum generated from the specified time
% bound.  The reference frequency is associated with the peak location in
% this spectrum.  The first expression searches the entire power spectrum,
% while the second expression limits the search to specified frequency
% range.
%
% See also PDV, configure
%

%%% UNDER CONSTRUCTION
% The first expression uses the entire power spectra from a specified
% time bound.  The
%
%     >> object=characterize(object,'Bandwidth');
%     >> object=characterize(object,'Bandwidth',tbound);
%
%     >> object=characterize(object,'NoiseFloor',tbound,fbound);
%%%

%
% created March 2, 2015 by Daniel Dolan (Sandia National Laboratories)
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
switch lower(mode)
    case 'bandwidth'
        
    case 'noisefloor'
        
    case 'referencefrequency'              
        % analyze bounded region
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
        [~,index]=max(P);
        object.Settings.ReferenceFrequency=f(index);        
    otherwise
        error('ERROR: %s is an invalid mode',mode);
end

end