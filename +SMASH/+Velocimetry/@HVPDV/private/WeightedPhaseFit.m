function [t0,fit]=WeightedPhaseFit(t,x,y)

phi=unwrap(atan2(y(:),x(:)));
duration=(t(end)-t(1));
q=(t(:)-t(1))/duration;

weight=x.^2+y.^2;
weight=weight/max(weight);

numpoints=numel(q);
order=3;
matrix=ones(numpoints,order+1);
for column=1:order
    matrix(:,column+1)=q.^column;
end

vector=phi;
matrixw=matrix;
for row=1:numpoints
    vector(row)=vector(row)*weight(row);
    matrixw(row,:)=matrixw(row,:)*weight(row);
end

param=matrixw\vector;
fit=matrix*param;

a=param(end:-1:1);
a=polyder(polyder(a));
q0=roots(a);
t0=t(1)+duration*q0;

end