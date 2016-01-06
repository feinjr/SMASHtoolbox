% qhist1 Quick histogram calculation for 1D values
%
%


function weight=qhist1(bin,value,bypass)

% manage input

% perform calculation
N=numel(bin);
dx=(bin(end)-bin(1))/(N-1);

v0=bin(1)-dx/2;
value=(value(:)-v0)/dx;
value=ceil(value)+1;
weight=accumarray(value,1,[N 1]);
weight=reshape(weight,size(bin));

end