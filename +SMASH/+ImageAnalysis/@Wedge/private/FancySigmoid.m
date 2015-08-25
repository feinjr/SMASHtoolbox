function varargout=FancySigmoid(x,y)

% manage input
N=numel(x);
assert(numel(y)==N,'ERROR: incompatible input arrays');
x=x(:);
y=y(:);
[x,index]=sort(x);
y=y(index);

L=x(end)-x(1);

% local derivative
xA=[];
LA=[];
xB=[];
LB=[];
gamma=[];
    function dydx=derivative(xd,~)
        dydx=zeros(size(xd));
        left=(xd<xA);
        xnorm=(xd(left)-xA)/LA;
        dydx(left)=exp(+xnorm);
        right=(xd>xB);        
        xnorm=(xd(right)-xB)/LB;
        dydx(right)=exp(-xnorm);
        inside=(xd>=xA) & (xd<=xB);
        dydx(inside)=1;
        if numel(gamma>0)
            xnorm=(xd(inside)-xA)/L;
            for k=1:numel(gamma)
                dydx(inside)=dydx(inside)+gamma(k)*xnorm.^k;
            end
        end
        dydx=dydx.^2;
    end

% residual function
fit=[];
matrix=ones(N,2);
vector=[];
Lmin=(x(end)-x(1))/100;
options=odeset('AbsTol',1e-6,'RelTol',1e-6);
 function chi2=residual(param)
     epsilonA=param(1);
     xA=(x(end)+x(1))/2+(x(end)-x(1))/2*sin(epsilonA);
     epsilonB=param(2);
     xB=(x(end)+xA)/2+(x(end)-xA)/2*sin(epsilonB);
     deltaA=param(3);
     LA=Lmin+deltaA^2;
     deltaB=param(4);
     LB=Lmin+deltaB^2;
     gamma=param(5:end);
     [~,I]=ode45(@derivative,x,0,options);
     matrix(:,2)=I;
     vector=matrix\y;
     fit=matrix*vector;
     chi2=(fit-y).^2;
     chi2=sum(chi2)/N;
    end

% initial fit
%guess=[-pi/4 +pi/4 0 0];
guess=[0 0 sqrt(Lmin) sqrt(Lmin)];
result=fminsearch(@residual,guess);
   
% revised fit
%result(end+1:end+3)=0;
result(end+1)=0;
result=fminsearch(@residual,result); 
residual(result); % generate fit with final parameter state

% manage output
if nargout==0
    xf=linspace(x(1),x(end),1000);
    [~,I]=ode45(@derivative,xf,0,options);
    matrix=ones(numel(I),2);
    matrix(:,2)=I;
    yf=matrix*vector;
    plot(x,y,'o',xf,yf);
else
    varargout{1}=fit;
    varargout{2}=result;
end

end