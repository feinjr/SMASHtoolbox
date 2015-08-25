function varargout=GeneralLogistic(x,y)

% manage input
N=numel(x);
assert(numel(y)==N,'ERROR: incompatible input arrays');
x=x(:);
y=y(:);
[x,index]=sort(x);
y=y(index);

% residual function
fit=[];
matrix=ones(N,2);
vector=[];
 function chi2=residual(param)
     C=param(1);
     x0=param(2);
     L=param(3);
     gamma=param(4);     
     xnorm=(x-x0)/L;
     matrix(:,2)=1./(1+C*exp(-xnorm)).^gamma;
     vector=matrix\y;
     fit=matrix*vector;
     chi2=(fit-y).^2;
     chi2=sum(chi2)/N;
    end
  
% perform fit
guess=[1 mean(x) (x(end)-x(1))/4 1];
result=fminsearch(@residual,guess); 
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