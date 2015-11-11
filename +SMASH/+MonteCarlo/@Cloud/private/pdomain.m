% pdomain : generate a two-dimensional domain that bounds a specified
%           sample probability
function [x,y]=pdomain(moments,correlations,Nsigma,numpoints)

% handle input
if (nargin<1) || isempty(moments)
    error('ERROR: moments table not specified');
end
L=size(moments,2);
if L<2
    error('ERROR: at least two statistical moments [mean std] are required');
elseif L<3
    moments(:,3)=0;
    moments(:,4)=0; % excess kurtosis
elseif L<4
    moments(:,4)=0; % excess kurtosis
else
    moments=moments(:,1:4);
end
N=size(moments,1);

if (nargin<2) || isempty(correlations)
    correlations=diag(diag(ones(N)));
elseif any(size(correlations)~=N)
    error('ERROR: moments table and correlation matrix are not compatible');
end
assert(all(diag(correlations)==1),'ERROR: invalid correlation matrix');
assert(correlations(2,1)==correlations(1,2),...
    'ERROR: invalid correlation matrix');
maxval=0.999;
if abs(correlations(2,1))>maxval
    correlations(2,1)=sign(correlations(2,1))*maxval;
    correlations(1,2)=correlations(2,1);
    warning('SMASH:pdomain','Correlation limited to +/- %f',maxval);
end


if (nargin<3) || isempty(Nsigma)
    Nsigma=1;
end

if (nargin<4) || isempty(numpoints)
    numpoints=100;
end

% create power function constants
[a,b,c,d]=deal(zeros(N,1));
for n=1:N    
   [b(n),c(n),d(n)]=sk2weights(moments(n,3:4));
   a(n)=-c(n);    
end

% create intermediate correlation matrix
intermediate=diag(diag(ones(N)));
p=zeros(1,4);
for m=1:N
    for n=(m+1):N        
        p(1)=6*d(m)*d(n);
        p(2)=2*c(m)*c(n);
        p(3)=b(m)*b(n)+3*b(m)*d(n)+3*d(m)*b(n)+9*d(m)*d(n);
        p(4)=-correlations(m,n);        
        rho=roots(p);        
        L2=real(rho).^2+imag(rho).^2;
        [L2,k]=min(L2);
        %if L2<=0.999;
            rho=real(rho(k));
        %else
        %    rho=sign(real(rho(k)))*0.999;
        %end       
        %[~,k]=min(abs(imag(rho)));
        %rho=real(rho(k));
        %if abs(rho)>1
        %    keyboard
        %end
        %keep=(abs(rho)<=1);
        %switch sum(keep)
        %    case 1
        %        rho=rho(keep);
        %    case 0
        %        [~,keep]=min(imag(rho));
        %        rho=rho(keep);
        %    case 2
        %        keyboard
        %    case 3
        %        keyboard
        %end        
        %rho=real(rho);
        intermediate(m,n)=rho;
        intermediate(n,m)=intermediate(m,n);
    end
end

% generate boundary curve
Q=chol(intermediate);
theta=linspace(0,2*pi,numpoints);
p=Nsigma*cos(theta);
q=Nsigma*sin(theta);
D=[p(:) q(:)];
X=D*Q;
data=zeros(numpoints,N);
for m=1:N   
    data(:,m)=a(m)+b(m)*X(:,m)+c(m)*X(:,m).^2+d(m)*X(:,m).^3;
    data(:,m)=sqrt(moments(m,2))*data(:,m)+moments(m,1);
end
x=data(:,1);
y=data(:,2);

% enfore wrap
x(end)=x(1);
y(end)=y(1);

end