% qhist1 Quick histogram calculation for 1D values
%
% This function quickly calculates histogram values for a uniformly spaced
% grid.
%   weight=qhist1(value,bin);
% NOTE: this function does generate histogram plots!  To display the
% results, use the plot or bar function.
%   plot(bin,weight);
%   bar(bin,weight,1);
%

%
% created January 6, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function weight=qhist1(value,bin)

% manage input
assert(nargin>=1,'ERROR: no values specified');

assert(nargin==2,'ERROR: no bins specified');
dx=diff(bin);
assert(all(dx>0),'ERROR: bin values must be increasing');
dx=mean(dx);
err=std(dx)/dx;
assert(err<1e-3,'ERROR: bin spacing must be uniform');

% perform calculation
N=numel(bin);
dx=(bin(end)-bin(1))/(N-1);

value=value(:);
value=round(value(:)/dx-bin(1)/dx)+1;
value(value<1)=1;
value(value>N)=N;

weight=accumarray(value,1,[N 1]);
%weight=full(sparse(1,value,1)); % OLD suggestion from Cleve Moler (slow!)
weight=reshape(weight,size(bin));

end