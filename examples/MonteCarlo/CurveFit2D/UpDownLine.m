function table=UpDownLine(param,xbound,ybound)

% extract parameters
m1=param(1);
x1=0;
y1=param(2);

x2=param(3);
m2=param(4);
y2=y1+m1*(x2-x1);

x=[xbound(1) x2 xbound(2)];
y=nan(size(x));
k=(x<=x2);
y(k)=y1+m1*(x(k)-x1);
k=(x>x2);
y(k)=y2+m2*(x(k)-x2);

table=[x(:) y(:)];

end