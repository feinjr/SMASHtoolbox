% MCinput : create input table for Monte Carlo simulations
%
% This function creates an input table with user-defined statistical
% properties.  Each row of the table contains the information for a single
% Monte Carlo iteration (i.e. the information passed to the evaluator
% function).  The first four statistical momentss (mean, variance, skewness,
% and excess kurtosis) of each column are specified by a moments table,
% where N is the number of columns needed in the input table.
%  Correlations between each column may also be specified.
%
% Usage:
% >> data=MCinput(moments,correlations,num_iterations);
%    -The moments table [Nx4] is required
%    -The (symmetric) correlation matrix [NxN] is optional.  The default
%    value of this input a NxN identity matrix
%    -The number of iterations is optional.  The default value is 100.

% created 2/11/2010 by Daniel Dolan
function data=MCinput(moments,correlations,num_iterations)

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

if (nargin<3) || isempty(num_iterations)
    num_iterations=100;
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
        keep=(abs(rho)<=1) & (imag(rho)<10*eps);
        rho=rho(keep);
        intermediate(m,n)=rho;
        intermediate(n,m)=intermediate(m,n);
    end
end

% generate random data
L=chol(intermediate);
D=randn(num_iterations,N);
X=D*L;
data=zeros(num_iterations,N);
for m=1:N   
    data(:,m)=a(m)+b(m)*X(:,m)+c(m)*X(:,m).^2+d(m)*X(:,m).^3;
    data(:,m)=sqrt(moments(m,2))*data(:,m)+moments(m,1);
end
data(1,:)=transpose(moments(:,1)); % first entry is mean location