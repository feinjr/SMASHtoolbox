% errorbar2     : Two dimensional error bar generator
% errobar2(x,y,dx,dy,hx,hy,options)
% 
function errorbar2(x,y,dx,dy,hx,hy,varargin)
if nargin<3
   error('Invalid number of arguments')
end
if isempty(dx)
   dx=zeros(size(x));
end
if (nargin<4) || isempty(dy)
   dy=zeros(size(y));
end
if length(dx)==1
   dx=ones(size(x))*dx;
end
if length(dy)==1
   dy=ones(size(y))*dy;
end
if (nargin<5) || isempty(hx);
   hx=dy/4;
end
if (nargin<6) || isempty(hy);
   hy=dx/4;
end
if length(hx)==1
   hx=ones(size(x))*hx;
end
if length(hy)==1
   hy=ones(size(x))*hy;
end

N=18; % number of "points" in each error bar
M=size(x);
if M(1)==1
   M(2)=M(2)*N;
else
   M(1)=M(1)*N;
end
xerr=zeros(M);
yerr=zeros(M);
ii=1:length(x);
L=length(xerr);
jj=1:N:L;
xerr(jj)=x(ii)-dx(ii);yerr(jj)=y(ii);
xerr(jj+1)=x(ii)+dx(ii);yerr(jj+1)=y(ii);
xerr(jj+2)=NaN;yerr(jj+2)=NaN;
xerr(jj+3)=x(ii);yerr(jj+3)=y(ii)+dy(ii);
xerr(jj+4)=x(ii);yerr(jj+4)=y(ii)-dy(ii);
xerr(jj+5)=NaN;yerr(jj+5)=NaN;
xerr(jj+6)=x(ii)-hx(ii);yerr(jj+6)=y(ii)+dy(ii);
xerr(jj+7)=x(ii)+hx(ii);yerr(jj+7)=y(ii)+dy(ii);
xerr(jj+8)=NaN;yerr(jj+8)=NaN;
xerr(jj+9)=x(ii)-hx(ii);yerr(jj+9)=y(ii)-dy(ii);
xerr(jj+10)=x(ii)+hx(ii);yerr(jj+10)=y(ii)-dy(ii);
xerr(jj+11)=NaN;yerr(jj+11)=NaN;
xerr(jj+12)=x(ii)-dx(ii);yerr(jj+12)=y(ii)+hy(ii);
xerr(jj+13)=x(ii)-dx(ii);yerr(jj+13)=y(ii)-hy(ii);
xerr(jj+14)=NaN;yerr(jj+14)=NaN;
xerr(jj+15)=x(ii)+dx(ii);yerr(jj+15)=y(ii)+hy(ii);
xerr(jj+16)=x(ii)+dx(ii);yerr(jj+16)=y(ii)-hy(ii);
xerr(jj+17)=NaN;yerr(jj+17)=NaN;

% plot 2D error bars
plot(xerr,yerr,varargin{:});