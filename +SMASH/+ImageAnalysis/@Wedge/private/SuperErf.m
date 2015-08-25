function varargout=SuperErf(x,y)

% manage input
N=numel(x);
assert(numel(y)==N,'ERROR: incompatible input arrays');
x=x(:);
y=y(:);
[x,index]=sort(x);
y=y(index);

% local derivative
x0=[];
N=[];
sigma=[];
E=[];
    function dydx=derivative(xd,~)        
        dydx=exp(-abs(xd-x0).^N./(2*sigma^N*(1+sign(xd)*E).^N));        
    end

% residual function
fit=[];
vector=[];
matrix=ones(numel(x),2);
 function [chi2,q]=residual(param)
     x0=param(1);
     N=param(2);
     sigma=param(3);
     E=param(4);     
     [~,column]=ode45(@derivative,x,0);      
     matrix(:,2)=column;
     vector=matrix\y;
     fit=matrix*vector;
     chi2=(fit-y).^2;
     chi2=sum(chi2)/numel(chi2);
    end

% perform fit
guess(4)=0; % E
guess(3)=(y(end)-y(1))/4; % sigma
guess(2)=2; % N
guess(1)=mean(x); % x0
result=fminsearch(@residual,guess(:)); 
residual(result);
result=[result; vector];

if nargout==0
    plot(x,y,'o',x,fit);
else
    varargout{1}=fit;
    varargout{2}=result;
end

end