function [data,param]=smoothBoundary(data,center,order)

numpoints=size(data,1);

data=bsxfun(@minus,data,center);
theta=atan2(data(:,2),data(:,1));
radius=bsxfun(@hypot,data(:,1),data(:,2));

basis=ones(numpoints,1+2*order);
column=1;
for m=1:order
    q=m*theta;
    column=column+1;
    basis(:,column)=cos(q);
    column=column+1;
    basis(:,column)=sin(q);
end
param=basis\radius;
fit=basis*param;

data(:,1)=center(1)+fit.*cos(theta);
data(:,2)=center(2)+fit.*sin(theta);

end