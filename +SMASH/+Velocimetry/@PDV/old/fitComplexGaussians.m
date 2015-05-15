function out=fitComplexGaussians(f,y,fA,fB,options)

% manage boundaries
Npoints=numel(f);
Nbound=numel(fA);
out=nan(Nbound,3);

location=(fA+fB)/2;
MasterIndex=1:numel(location);
keep=~isnan(location);
location=location(keep);
fA=fA(keep);
fB=fB(keep);
fmid=(fA+fB)/2;
famp=(fB-fA)/2;
MasterIndex=MasterIndex(keep);
Nbound=numel(MasterIndex);

% perform optimization
    function [chi2,fit,full]=residual(parameter)
        % array allocation
        [P,Q]=deal(nan(Npoints,numel(MasterIndex))); % real/imaginary basis 
        full=nan(Nbound,3); % [location width amplitude] parameters
        % calculate basis functions
        for m=1:Nbound
            b=fmid(m)+famp(m)*sin(parameter(m,1)); % beat frequency
            c=parameter(m,2); % chirp factor
            sigma2=4*pi^2*options.Tau^2;
            sigma2=(1+4*c^2*sigma2)/sigma2;
            Bplus =exp(-(b-f).^2/(2*sigma2));
            Bminus=exp(-(b+f).^2/(2*sigma2));
            P(:,m)=Bplus+Bminus;
            Q(:,m)=Bplus-Bminus;
            full(m,1)=b;
            full(m,2)=sqrt(sigma2);
        end
        % enforce uniqueness tolerance
        keep=true(1,Nbound);
        for m=2:Nbound
            for n=1:(m-1)
                Im=trapz(f,P(:,m));
                In=trapz(f,P(:,n));
                Imn=trapz(f,(P(:,m)-P(:,n)).^2);
                if (Imn/(Im*In))>=options.UniqueTolerance
                    continue
                end
                Im=trapz(f,Q(:,m));
                In=trapz(f,Q(:,n));
                Imn=trapz(f,(Q(:,m)-Q(:,n)).^2);
                if (Imn/(Im*In))>=options.UniqueTolerance
                    continue
                end
                keep(m)=false;
            end
        end
        P=P(:,keep);
        Q=Q(:,keep);
        keep=find(keep);
        % determine scale factors and residual
        pu=P\real(y);
        qu=Q\imag(y);        
        fit=(P*pu+1i*Q*qu);
        chi2=y-fit;
        chi2=mean(real(chi2.*conj(chi2)));
        % complete full parameter array
        for m=keep
            full(m,3)=pu(m).^2+qu(m).^2;
        end                  
    end

guess=zeros(Nbound,2);
%guess(:,1)=location(:);
parameter=fminsearch(@residual,guess);
[~,fit,full]=residual(parameter);
if full(3)<1.5e-23
    keyboard
end

% store results
for k=1:Nbound
    out(MasterIndex(k),:)=full(k,:);
end

end