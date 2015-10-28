function [fit,param,Dparam]=WeightedLineFit(x,y,dy)

weight=1./dy.^2;
Delta=sum(weight)*sum(weight.*x.^2)-sum(weight.*x).^2;

A=sum(weight.*x.^2)*sum(weight.*y)-sum(weight.*x)*sum(weight.*x.*y);
A=A/Delta;
DA=sqrt(sum(weight.*x.^2)/Delta);

B=sum(weight)*sum(weight.*x.*y)-sum(weight.*x)*(sum(weight.*y));
B=B/Delta;
DB=sqrt(sum(weight)/Delta);

param=[B A]; % MATLAB convention
Dparam=[DB DA];
fit=polyval(param,x);

end