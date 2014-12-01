% generate Generate new cloud using moments and correlations
%
% This method generates new cloud Data using the current moments and
% correlation matrix.
%    >> new=generate(object);
% The new object is essentially a redraw from the same distribution as
% the source object.
%
% See also Cloud, bootstrap
%

%
% created August 5, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=generate(object)

% seed random generator
seed=object.Seed;
if ischar(seed)
    % convert string to number
end
if ~isempty(seed)
    s=RandStream('mt19937ar','Seed',seed);
    RandStream.setGlobalStream(s);
end
% generate table from moments/correlations
object.Data=MCinput(object.Moments,object.Correlations,...
    object.NumberPoints);
object.Source='generate';


end