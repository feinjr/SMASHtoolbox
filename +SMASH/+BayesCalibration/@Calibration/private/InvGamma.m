function [l,dl] = InvGamma(a,b,x)

% The inverse Gamma distribution is parameterized as : 
%
%   p(x) = 
%
% where a is the shape and b is the rate parameter. 
%
%
% created June 24, 2016 by Justin Brown (Sandia National Laboratories)
%

%Error checking
if nargin<2
    error('ERROR : Shape(a) and rate(b) need to be provided')
end
if ~(isscalar(a) && isscalar(b))
    error('ERROR : a and b need to be scalars')
end
if nargin == 2
    
    l = 1./Gamma(a,1./b);
  
elseif nargin == 3
    %Return the log-likelihood and it's derivative

    %l = -(a+1).*log(x)-gammaln(a)+a.*log(b)-b./x;
    %dl = -(a+1)./x + b./(x.^2);
    
    N = numel(x);
    l = -N*(a+1).*sum(log(x))-N.*gammaln(a)+N.*a.*log(b)-sum(b./x);
    dl = -N*(a+1)./sum(x) + sum(b./x.^2);
    l(x<0) = -inf; dlp(x<0) = 0;
    
    
    
else
    error('ERROR : Too many input parameters')
end

end
