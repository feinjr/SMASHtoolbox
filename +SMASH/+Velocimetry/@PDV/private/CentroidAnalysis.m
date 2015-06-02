function out=CentroidAnalysis(f,y,t,~,boundary)

tmid=(t(end)+t(1))/2;

Nboundary=numel(boundary);
out=nan(Nboundary,4);
for k=1:Nboundary
    [fA,fB]=probe(boundary{k},tmid);
    if isnan(fA) || isnan(fB)
        continue
    end
    index=(f>=fA)&(f<=fB);
    fb=f(index);
    w=y(index);
    area=trapz(fb,w); % area
    w=w/area;
    out(k,1)=trapz(fb,w.*fb); % beat frequency
    out(k,2)=trapz(fb,w.*(fb-out(k,1)).^2); %
    out(k,2)=sqrt(out(k,2)); % standard deviation
    %out(k,3)=out(k,3)/out(k,2); % height estimate
    out(k,3)=area/(sqrt(2*pi)*out(k,2)); % estimated power
    out(k,4)=true; % unique flag
end
out=transpose(out);
out=out(:);

end