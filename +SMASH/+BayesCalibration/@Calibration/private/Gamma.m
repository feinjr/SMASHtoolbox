function [l,dl] = Gamma(k,t,x)

% The Gamma distribution is parameterized as : 
%
%   p(x) = exp(x/t)/gamma(k)*x^(k-1)/t^k
%
% where k is the shape and t is the scale parameter. 
%
%
% created June 24, 2016 by Justin Brown (Sandia National Laboratories)
%

%Error checking
if nargin<2
    error('ERROR : Mean and standard deviation need to be provided')
end
if ~(isscalar(k) && isscalar(t))
    error('ERROR : a and b need to be scalars')
end
if nargin == 2
    
      m = 1;
      d = k-floor(k); % fractional part
      v0 = exp(1)/(exp(1)+d);
      while true
        v = rand(3,1);
        if v(1)<=v0
          r = v(2)^(1/d); s = v(3)*r^(d-1);
        else
          r = 1-log(v(2)); s = v(3)*exp(-r);
        end
        if s<=r^(d-1)*exp(-r), break, end
        m = m+1;
      end
      u = rand(floor(k),1);
      l = t*(r-sum(log(u)));
  
    
elseif nargin == 3
    %Return the log-likelihood and it's derivative
    %lx = log(x);
    %l  = -gammaln(k) - k*log(t) + (k-1)*lx - x/t;
    %dl = (k-1)./x - 1/t;
    
    
    N = numel(x);
    l = (k-1).*sum(log(x))-N.*k-sum(x./t)-N*k*log(t)-N.*gammaln(k);
    dl = (k-1)./sum(x) - N./t;  
    l(x<0) = -inf; dlp(x<0) = 0;
    
else
    error('ERROR : Too many input parameters')
end

end
