% regenerate Generate new data from an existing cloud
%
% This method generates new cloud data using the current moments and
% correlations.
%    >> new=regenerate(object);
%    >> new=regenerate(object,'moments'); % same as above
%
% See also Cloud, bootstrap
%

%
% created August 5, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised July 3, 2015 by Daniel Dolan
%   -changed method from generate to regenerate
%   -merged with bootstrap method
%
function object=regenerate(object)

% manage random number generator
if isempty(object.Seed)
    % do nothing
else
    if ischar(object.Seed)
        seed=sum(double(object.Seed));
    else
        seed=object.Seed;
    end
    rng(seed);
end

% regenerate cloud data
object.Data=MCinput(object.Moments,object.Correlations,...
    object.NumberPoints);

object.Source='moments';

end