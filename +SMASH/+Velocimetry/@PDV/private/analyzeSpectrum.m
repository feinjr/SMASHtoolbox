function history=analyzeSpectrum(measurement,boundary,setting,mode)

%% manage input
if (nargin<4) || isempty(mode)
    mode='centroid';
end
assert(ischar(mode),'ERROR: invalid spectrum analysis mode');

%% set up local analysis
Nboundary=numel(boundary);
    function parameter=findPeak(f,y,t,s,boundary)
        tmid=(t(end)+t(1))/2;
        parameter=nan(Nboundary,4); % [center chirp amplitude uncertainty]
        %% analyze active bounds
        for index=1:Nboundary
            [fA,fB]=probe(boundary{index},tmid);
            if isnan(fA) || isnan(fB)
                continue
            end
            keep=(f>=fA)&(f<=fB);
            fb=f(keep);
            y=y(keep);
            switch lower(mode)
                case 'centroid'
                    area=trapz(fb,y);
                    weight=y/area;
                    center=trapz(fb,weight.*fb);
                    parameter(index,1)=center;
                    parameter(index,3)=interp1(fb,y,center,'linear');
                    % parameter 4 is uncertainty!
                otherwise
                    error('ERROR: invalid spectrum analysis mode');
            end            
        end
        
        %% manage output
        parameter=transpose(parameter);
        parameter=parameter(:);
    end

%% perform analysis
measurement.FFToptions.SpectrumType='power';

history=analyze(measurement,@findPeak,'none');

end