function history=analyzeSpectrum(measurement,boundary,setting,varargin)

% manage input
Nboundary=numel(boundary);

% set up local analysis
    function parameter=processBlock(f,P,t,~)
        tmid=(t(end)+t(1))/2;
        parameter=nan(4,Nboundary); % [center amplitude chirp unique]
        % chirp and unique are not used in spectrum analysis
        for index=1:Nboundary
            [fA,fB]=probe(boundary{index},tmid);
            if isnan(fA) || isnan(fB)
                continue
            end
            keep=(f>=fA) & (f<=fB);
            [center,amplitude]=findPeak(f(keep),P(keep),varargin{:});                        
            parameter(1,index)=center;
            %parameter(2,index)=amplitude/setting.DomainScaling;
            parameter(2,index)=sqrt(amplitude/setting.DomainScaling);
        end        
        parameter=parameter(:);
    end

% perform analysis
measurement.FFToptions.SpectrumType='power';
history=analyze(measurement,@processBlock,'none');

end