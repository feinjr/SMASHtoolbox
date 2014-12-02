% evaluate Evaluate Curve at specified locations
%
% This method evaluates a Curve object at specified locations:
%     >> y=evaluate(object,x);
% using the current basis parameters and scaling factors.
%
% See also Curve, fit, summarize
%

%
% created December 1, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function [y,basis]=evaluate(object,x)

x=x(:);
M=numel(x);

N=numel(object.Basis);
basis=zeros(M,N);
for n=1:N
    basis(:,n)=feval(object.Basis{n},object.Parameter{n},x);
    basis(:,n)=object.Scale{n}*basis(:,n);
end
y=sum(basis,2);

end