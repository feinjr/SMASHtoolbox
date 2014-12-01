function param=linefit(x,y,w)

x=x(:);
y=y(:);
w=w(:);
guess=polyfit(x,y,1);
w=w/sum(w); % normalize weights
    function [chi2,fit]=residual(param)
        fit=polyval(param,x);
        chi2=sum(w.*(y-fit).^2);        
    end
param=fminsearch(@residual,guess);

end