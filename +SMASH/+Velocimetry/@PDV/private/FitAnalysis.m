function out=FitAnalysis(f,y,t,~,boundary,options)

% determine active frequency bounds
tmid=(t(end)+t(1))/2;
%if (tmid>=2663) && (tmid<=2665)
%    keyboard
%end

Nboundary=numel(boundary);
[fA,fB]=deal(nan(Nboundary,1));
active=true(Nboundary,1);
for k=1:Nboundary
    [fA(k),fB(k)]=probe(boundary{k},tmid);
    if isnan(fA(k))
        active(k)=false;
    end
end
active=find(active);
Nactive=numel(active);
%fA=fA(active);
%fB=fB(active);

fmid=(fA+fB)/2;
famp=(fB-fA)/2;

% shock management (UNDER CONSTRUCTION)

% harmonic management (UNDER CONSTRUCTION)

% perform optimization
guess=zeros(Nactive,2);
Npoints=numel(f);
[X,Y]=deal(zeros(Npoints,Nactive));
    function [chi2,fit,full]=residual(parameter)
        full=nan(Nactive,3);
        for column=1:Nactive
            bound=active(column);
            b=fmid(bound)+famp(bound)*sin(parameter(bound,1));
            full(bound,1)=b;
            c=parameter(bound,2);
            full(bound,2)=c;
            sigma2=4*pi^2*options.Tau^2;
            sigma2=(1+4*c^2*sigma2)/sigma2;
            Bplus =exp(-(b-f).^2/(2*sigma2));
            Bminus=exp(-(b+f).^2/(2*sigma2));
            X(:,column)=Bplus+Bminus;
            Y(:,column)=Bplus-Bminus;            
        end 
        [p,~]=linsolve(X,real(y));
        [q,~]=linsolve(Y,imag(y));
        fit=(X*p+1i*Y*q);
        chi2=y-fit;
        chi2=mean(real(chi2.*conj(chi2)));
        full(:,3)=p.^2+q.^2;
    end
parameter=fminsearch(@residual,guess);
[~,fit,parameter]=residual(parameter); % X and Y updated here

% enforce uniqueness
isUnique=true(Nactive,1);
for m=1:Nactive
    for n=(m+1):Nactive
        Im=trapz(f,X(:,m));
        In=trapz(f,X(:,n));
        Imn=trapz(f,(X(:,m)-X(:,n)).^2);
        if (Imn/(Im*In))>=options.UniqueTolerance
            continue
        end
        Im=trapz(f,Y(:,m));
        In=trapz(f,Y(:,n));
        Imn=trapz(f,(Y(:,m)-Y(:,n)).^2);
        if (Imn/(Im*In))>=options.UniqueTolerance
            continue
        end
        isUnique(m)=false;
    end
end
parameter(~isUnique,end)=nan;

% manage output
out=nan(Nboundary,4);
out(active,:)=parameter;
out=out(:);


end

% function out=fitComplexGaussians(f,y,fA,fB,options)
% 
% % manage boundaries
% %Npoints=numel(f);
% %Nbound=numel(fA);
% %out=nan(Nbound,3);
% 
% location=(fA+fB)/2;
% MasterIndex=1:numel(location);
% keep=~isnan(location);
% location=location(keep);
% fA=fA(keep);
% fB=fB(keep);
% fmid=(fA+fB)/2;
% famp=(fB-fA)/2;
% MasterIndex=MasterIndex(keep);
% Nbound=numel(MasterIndex);
% 
% % perform optimization
%     function [chi2,fit,full]=residual(parameter)
%         % array allocation
%         [P,Q]=deal(nan(Npoints,numel(MasterIndex))); % real/imaginary basis
%         full=nan(Nbound,3); % [location width amplitude] parameters
%         % calculate basis functions
%         for m=1:Nbound
%             b=fmid(m)+famp(m)*sin(parameter(m,1)); % beat frequency
%             c=parameter(m,2); % chirp factor
%             sigma2=4*pi^2*options.Tau^2;
%             sigma2=(1+4*c^2*sigma2)/sigma2;
%             Bplus =exp(-(b-f).^2/(2*sigma2));
%             Bminus=exp(-(b+f).^2/(2*sigma2));
%             P(:,m)=Bplus+Bminus;
%             Q(:,m)=Bplus-Bminus;
%             full(m,1)=b;
%             full(m,2)=sqrt(sigma2);
%         end
%         % enforce uniqueness tolerance
%         keep=true(1,Nbound);
%         for m=2:Nbound
%             for n=1:(m-1)
%                 Im=trapz(f,P(:,m));
%                 In=trapz(f,P(:,n));
%                 Imn=trapz(f,(P(:,m)-P(:,n)).^2);
%                 if (Imn/(Im*In))>=options.UniqueTolerance
%                     continue
%                 end
%                 Im=trapz(f,Q(:,m));
%                 In=trapz(f,Q(:,n));
%                 Imn=trapz(f,(Q(:,m)-Q(:,n)).^2);
%                 if (Imn/(Im*In))>=options.UniqueTolerance
%                     continue
%                 end
%                 keep(m)=false;
%             end
%         end
%         P=P(:,keep);
%         Q=Q(:,keep);
%         keep=find(keep);
%         % determine scale factors and residual
%         pu=P\real(y);
%         qu=Q\imag(y);
%         fit=(P*pu+1i*Q*qu);
%         chi2=y-fit;
%         chi2=mean(real(chi2.*conj(chi2)));
%         % complete full parameter array
%         for m=keep
%             full(m,3)=pu(m).^2+qu(m).^2;
%         end
%     end
% 
% guess=zeros(Nbound,2);
% %guess(:,1)=location(:);
% parameter=fminsearch(@residual,guess);
% [~,fit,full]=residual(parameter);
% if full(3)<1.5e-23
%     keyboard
% end
% 
% % store results
% for k=1:Nbound
%     out(MasterIndex(k),:)=full(k,:);
% end
% 
% end