function out=twist(z,theta)

% convert angle from degrees to radians
theta=theta*(pi/180);

% create (x,y) grid
[N,M]=size(z);
x=1:M;
x=x-mean(x);
y=1:N;
y=y-mean(y);
[x,y]=meshgrid(x,y);

% create interpolation grid
xi=+cos(theta)*x(:)-sin(theta)*y(:);
yi=+sin(theta)*x(:)+cos(theta)*y(:);
xi=reshape(xi,size(x));
yi=reshape(yi,size(y));

% interpolate image onto new grid
out=interp2(x,y,z,xi,yi,'linear');

end