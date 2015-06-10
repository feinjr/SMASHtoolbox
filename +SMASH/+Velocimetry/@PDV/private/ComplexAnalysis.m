function out=FitAnalysis(f,y,t,~,boundary,options)

% determine active frequency bounds
tmid=(t(end)+t(1))/2;

Nboundary=numel(boundary);
[fA,fB]=deal(nan(Nboundary,1));
active=true(Nboundary,1);
for k=1:Nboundary
    [fA(k),fB(k)]=probe(boundary{k},tmid);
    if isnan(fA(k))
        active(k)=false;
    end
end
Nactive=sum(active);

fmid=(fA+fB)/2;
famp=(fB-fA)/2;

% shock management (UNDER CONSTRUCTION)

% harmonic management (UNDER CONSTRUCTION)

% perform optimization
guess=zeros(Nactive,1);
Npoints=numel(f);
[X,Y]=deal(zeros(Npoints,Nactive));
parameter=nan(Nboundary,4); % full parameter array
    function [chi2,fit]=residual(p)
        column=1;
        for index=1:Nboundary
            if ~active(index)
                continue
            end                                 
            b=fmid(index)+famp(index)*sin(p(column,1));
            parameter(index,1)=b;
            %c=p(column,2);
            c=0;
            parameter(index,2)=c;
            sigma2=4*pi^2*options.Tau^2;
            sigma2=(1+4*c^2*sigma2)/sigma2;
            Bplus =exp(-(b-f).^2/(2*sigma2));
            Bminus=exp(-(b+f).^2/(2*sigma2));
            X(:,column)=Bplus+Bminus;
            Y(:,column)=Bplus-Bminus;      
            column=column+1;
        end 
        [p,~]=linsolve(X,real(y));
        [q,~]=linsolve(Y,imag(y));
        fit=(X*p+1i*Y*q);
        chi2=y-fit;
        chi2=mean(real(chi2.*conj(chi2)));
        parameter(active,3)=p.^2+q.^2;
        parameter(active,4)=true;
    end
SearchOptions=optimset('Display','off');
[partial,fval,exitflag,output]=fminsearch(@residual,guess,SearchOptions);
%if (parameter(1,1)<0.5) || (parameter(2,1)>1.5)
%    keyboard
%end

%if exitflag==0
%    %[~,fit]=residual(partial); % X,Y, and parameter updated here
%    %showComplexFits(f,y,fit)
%    %keyboard
%    fprintf('%.1f\n',tmid);
%end
[~,fit]=residual(partial); % X,Y, and parameter updated here

ratio=min(parameter(:,3))/max(parameter(:,3));
if ratio<0.1
    keyboard;
end

% determine uniqueness
for m=1:Nboundary
    if ~active(m)
        continue
    end
    for n=1:(m-1)
        if ~active(n)
            continue
        end
        Im=trapz(f,X(:,m));
        In=trapz(f,X(:,n));
        Imn=trapz(f,(X(:,m)-X(:,n)).^2);
        if (Imn/(Im*In)) >= options.UniqueTolerance
            continue
        end
        Im=trapz(f,Y(:,m));
        In=trapz(f,Y(:,n));
        Imn=trapz(f,(Y(:,m)-Y(:,n)).^2);
        if (Imn/(Im*In)) >= options.UniqueTolerance    
            continue
        end
        parameter(m,4)=false;
        break
    end
    if ~parameter(m,4)
        break
    end
end

% manage output
parameter=transpose(parameter);
out=parameter(:);


end