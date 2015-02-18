%
%     >> object=characterize(object,'ReferenceFrequency');
%     >> object=characterize(object,'ReferenceFrequency',tbound);
%     >> object=characterize(object,'ReferenceFrequency',tbound,fbound);
%
%     >> object=characterize(object,'Bandwidth');
%     >> object=characterize(object,'Bandwidth',tbound);
%
%     >> object=characterize(object,'NoiseFloor',tbound,fbound);
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
        object.Parameter.ReferenceFrequency=f(index);

        
    otherwise
        error('ERROR: invalid mode request');
end

end