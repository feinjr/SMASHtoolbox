function [l,dl] = Uniform(lb,ub,x)

% The uniform distribution is parameterized as:
%
%   p(x)    = 0 for x < lb
%           = 1/(ub-lb) for lb <= x <= ub
%           = 0 for x > ub
%
% where lb is the lower bound and ub is the upper bound. If x is specifed,
% the log-likelihood and it's derivative are returned. If x is not
% specified, a random sample is drawn from the distribution.

%
% created June 22, 2016 by Justin Brown (Sandia National Laboratories)
%

%Error checking
if nargin<2
    error('ERROR : Lower and upper bounds need to be provided')
end
if ~(isscalar(ub) && isscalar(lb))
    error('ERROR : Lower and upper bounds need to be scalars')
end
if nargin == 2

    l = lb+(ub-lb).*rand(1); % return a sample from the distribution

elseif nargin == 3
    
    %Return the log-likelihood and it's derivative
    if x<lb || x >ub
        l = -inf;
        dl = -inf;
    else
        N = numel(x);
        l  = -N.*log(ub-lb);
        dl = 0;
    end
    
    
else
    error('ERROR : Too many input parameters')
end

end