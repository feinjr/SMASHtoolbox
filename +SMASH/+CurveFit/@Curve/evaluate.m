function [y,basis]=evaluate(object,x)

x=x(:);
M=numel(x);
y=zeros(M,1);

N=numel(object.Basis);
basis=zeros(M,N);
for n=1:N
    basis(:,n)=feval(object.Basis{n},object.Parameter{n},x);
    basis(:,n)=object.Scale{n}*basis(:,n);
end
y=sum(basis,2);

end