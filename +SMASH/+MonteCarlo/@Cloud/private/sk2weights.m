%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert skew and kurtosis to weights %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [b,c,d]=sk2weights(moments)
skew=moments(1);
kurtosis=moments(2);

z=zeros(3,1);
Q=zeros(3,3);
b=1;
c=0;
d=0;
for iter=1:10
    % update vector elements    
    z(1)=b^2+6*b*d+2*c^2+15*d^2-1;
    z(2)=2*c*(b^2+24*b*d+105*d^2+2)-skew;
    z(3)=24*(b*d+c^2*(1+b^2+28*b*d)+d^2*(12+48*b*d+141*c^2+225*d^2))-kurtosis;
    % update matrix elements
    Q(1,1)=2*b+6*d;
    Q(1,2)=4*c;
    Q(1,3)=6*b+30*d;
    Q(2,1)=2*c*(2*b+24*d);
    Q(2,2)=2*(b^2+24*b*d+105*d^2+2);
    Q(2,3)=2*c*(24*b+210*d);
    Q(3,1)=24*(d+c^2*(2*b+28*d)+d^2*(48*d));
    Q(3,2)=24*(2*c*(1+b^2+28*b*d)+d^2*(282*c));
    Q(3,3)=24*(b+c^2*(28*b)+2*d*(12+48*b*d+141*c^2+225*d^2)+d^2*(48*b+450*d));
    % Newton step
    x=[b; c; d;];
    dx=-(Q\z);
    x=x+dx;
    b=x(1);
    c=x(2);
    d=x(3);   
end