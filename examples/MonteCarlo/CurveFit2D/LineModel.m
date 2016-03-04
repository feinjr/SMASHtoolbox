function table=LineModel(param,xdomain,ydomain)

x=xdomain;
y=polyval(param,x);

table=[x(:) y(:)];

end