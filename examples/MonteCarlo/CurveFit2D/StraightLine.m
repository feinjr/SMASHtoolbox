function table=StraightLine(param,xdomain,ydomain)

x=xdomain;
y=polyval(param,x);

table=inf(numel(x)+2,2);
table(2:end-1,:)=[x(:) y(:)];

end