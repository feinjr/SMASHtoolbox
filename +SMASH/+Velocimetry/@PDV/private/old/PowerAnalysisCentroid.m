
function parameter=PowerAnalysisCentroid(f,y,t,~,boundary)%,options)

%% general setup
tmid=(t(end)+t(1))/2;
Nboundary=numel(boundary);
parameter=nan(Nboundary,4);

%% analyze active bounds
for index=1:Nboundary
    [fA,fB]=probe(boundary{index},tmid);
    if isnan(fA) || isnan(fB)
        continue
    end    
    keep=(f>=fA)&(f<=fB);
    fb=f(keep);
    weight=y(keep);
    area=trapz(fb,weight); % area
    weight=weight/area;
    parameter(index,1)=trapz(fb,weight.*fb); % center
    parameter(index,2)=trapz(fb,weight.*(fb-parameter(index,1)).^2);
    parameter(index,2)=sqrt(parameter(index,2)); % width (standard deviation)
    %parameter(index,3)=area/(sqrt(2*pi)*parameter(index,2));
    parameter(index,3)=max(weight)*area;
    %parameter(index,3)=sqrt(parameter(index,3))*options.ScaleFactor; % estimated signal amplitude
    % uniqueness not used here
end

%% manage output
parameter=transpose(parameter);
parameter=parameter(:);

end