% verify Verify cloud statistics
%
% This method verifies the statistical moments and correlations in a data
% cloud.  Confidence estimates are generated from bootstrap replications of
% the original cloud.

function varargout=verify(object,iterations,span)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=1000;
end
assert(isnumeric(iterations) && isscalar(iterations)...
    && (iterations>0) && (iterations==round(iterations)),...
    'ERROR: invalid iterations value');
if iterations<100
    warning('SMASH:Cloud','At least 100 iterations should be used to verify a cloud');
end

if (nargin<3) || isempty(span)
    span=erf(1/sqrt(2));
end
assert(isnumeric(span),'ERROR: invalid span value');
if numel(span)==1
    low=(1-span)/2;
    high=1-low;
else
    span=sort(span);
    low=span(1);
    high=span(2);
end
assert((low>0) && (high<1),'ERROR: span values')

% bootstrap analysis


% manage output



end