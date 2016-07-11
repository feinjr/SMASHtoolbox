function [l,dl] = Gauss(mu,sig,x)

% The Gaussian distribution is parameterized as:
%
%   p(x) = exp(-(x-mu)^2/(2*sig^2)) / sqrt(2*pi*sig^2), where
%
% mu is the mean, sig is the standard deviation  and x are values to 
% evaluate. If x is given, the log-likelihood and it's derivative are
% returned. If x is not given, a random sample is returned.

%
% created June 22, 2016 by Justin Brown (Sandia National Laboratories)
%

%Error checking
if nargin<2
    error('ERROR : Mean and standard deviation need to be provided')
end
if ~(isscalar(mu) && isscalar(sig))
    error('ERROR : mu and sigma need to be scalars')
end
if nargin == 2
    l = sig*randn+mu; % return a sample from the distribution
elseif nargin == 3
    %Return the log-likelihood and it's derivative
    s2 = sig^2;
    %l  = -(x-mu).^2/(2*s2) - log(2*pi*s2)/2;
    %dl = -(x-mu)/s2;
    
    N = numel(x);
    l = -N/2*log(2*pi*s2)-sum((x-mu).^2)./(2*s2);
    dl = -sum(x-mu)./(s2);
    
    
else
    error('ERROR : Too many input parameters')
end

end
