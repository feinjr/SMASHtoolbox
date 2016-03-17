function history=analyzeSpectrum(measurement,boundary,setting,mode)

% manage input
if (nargin<4) || isempty(mode)
    mode='centroid';
end
assert(ischar(mode),'ERROR: invalid spectrum analysis mode');

% set up local analysis
Nboundary=numel(boundary);
    function parameter=findPeak(f,y,t,~)
        tmid=(t(end)+t(1))/2;
        parameter=nan(4,Nboundary); % [center amplitude chirp unique]
        % chirp and unique are not used in spectrum analysis
        for index=1:Nboundary
            [fA,fB]=probe(boundary{index},tmid);
            if isnan(fA) || isnan(fB)
                continue
            end
            keep=(f>=fA) & (f<=fB);
            fb=f(keep);
            yb=y(keep);
            threshold=max(yb)*0.10;
            switch lower(mode)
                case 'centroid'
                    weight=yb;
                    weight(weight<threshold)=0;                            
                    area=trapz(fb,weight);
                    weight=weight/area;
                    center=trapz(fb,weight.*fb);
                    %width=sqrt(trapz(fb,weight.*(fbb-center).^2));
                    %fprintf('%3d %#g %#g\n',iteration,center,width);
                    %left=center-width;
                    %right=center+width;                                                                                                                                                               
                    amplitude=interp1(fb,yb,center,'linear');                    
                otherwise
                    error('ERROR: invalid spectrum analysis mode');
            end   
            parameter(1,index)=center;
            parameter(2,index)=amplitude/setting.DomainScaling;
        end        
        parameter=parameter(:);
    end

% perform analysis
measurement.FFToptions.SpectrumType='power';
history=analyze(measurement,@findPeak,'none');

end