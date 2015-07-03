% regenerate Generate new data from an existing cloud
%
% This method generates new cloud data from an existing cloud object.  By
% default, data is generated from the current moments and correlations.
%    >> new=generate(object);
%    >> new=generate(object,'moments'); % same as above
% Bootstrapping can also be used to resample the current cloud data.
%    >> new=generate(object,'bootstrap'); 
% The moments and correlations of a resampled cloud are revised for
% consistency with the data.
%
% See also Cloud
%

%
% created August 5, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised July 3, 2015 by Daniel Dolan
%   -changed method from generate to regenerate
%   -merged with bootstrap method
%
function object=regenerate(object,mode)

% manage input
if (nargin<2) || isempty(mode)
    mode='moments';
end
assert(ischar(mode),'ERROR: invalid mode requested');
mode=lower(mode);

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
switch mode
    case 'moments'
        object.Data=MCinput(object.Moments,object.Correlations,...
            object.NumberPoints);
    case 'bootstrap'
        index=randi(object.NumberPoints,[object.NumberPoints 1]);
        object.Data=object.Data(index,:);
        [moments,correlations]=summarize(object);
        object.Moments=moments;
        object.Correlations=correlations;
    otherwise
        error('ERROR: invalid mode requested');
end
object.Source=mode;

end