function history=analyzeSpectrum(measurement,boundary,setting,mode)

% manage input
if (nargin<4) || isempty(mode)
    mode='centroid';
end
assert(ischar(mode),'ERROR: invalid spectrum analysis mode');

% set up local analysis
Nboundary=numel(boundary);
fs=setting.SampleRate;
tau=setting.BoxcarDuration;
sigma=setting.RMSnoise;
UncertaintyFactor=sqrt(6/fs*tau^3)*sigma/pi;
    function parameter=findPeak(f,y,t,~)
        tmid=(t(end)+t(1))/2;
        parameter=nan(4,Nboundary); % [center uncertainty chirp unique]
        for index=1:Nboundary
            [fA,fB]=probe(boundary{index},tmid);
            if isnan(fA) || isnan(fB)
                continue
            end
            keep=(f>=fA)&(f<=fB);
            fb=f(keep);
            yb=y(keep);
            switch lower(mode)
                case 'centroid'
                    area=trapz(fb,yb);
                    weight=yb/area;
                    center=trapz(fb,weight.*fb);
                    parameter(1,index)=center;                    
                    amplitude=interp1(fb,yb,center,'linear');                                               
                otherwise
                    error('ERROR: invalid spectrum analysis mode');
            end     
            amplitude=amplitude/setting.DomainScaling;    
            uncertainty=UncertaintyFactor/amplitude;
            parameter(2,index)=uncertainty;
            parameter(4,index)=true;
        end        
        parameter=parameter(:);
    end

% perform analysis
measurement.FFToptions.SpectrumType='power';
history=analyze(measurement,@findPeak,'none');

end