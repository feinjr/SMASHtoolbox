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
mode=lower(mode);

Narg=numel(varargin);

% perform characterization
switch mode
    case 'bandwidth'
        
    case 'noisefloor'
        
    case 'referencefrequency'
        % determine bounds
        tbound=[-inf +inf];
        fbound=[-inf +inf];
        if Narg>=1
            tbound=varargin{1};
        end
        if Narg==2
            fbound=varargin{2};
        elseif Narg>2
            error('ERROR: too many inputs');
        end
        assert(isnumeric(tbound) && (numel(tbound)==2),...
            'ERROR: invalid time range');
        tbound=sort(tbound);
        assert(isnumeric(fbound) && (numel(fbound)==2),...
            'ERROR: invalid frequency range');
        fbound=sort(fbound);
        % analyze bounded region
        temp=object.Measurement;
        temp=limit(temp,'all');
        temp=crop(temp,tbound);
        %temp=crop(object.Measurement,tbound);
        [f,P]=fft(temp,'FrequencyDomain','positive','SpectrumType','power',...
            'NumberFrequencies',1e6);
        keep=(f>=fbound(1)) & (f<=fbound(2));
        f=f(keep);
        P=P(keep);
        [~,index]=max(P);
        object.Settings.ReferenceFrequency=f(index);        
    otherwise
        error('ERROR: invalid mode request');
end

end