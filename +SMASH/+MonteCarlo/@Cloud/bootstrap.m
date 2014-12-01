% bootstrap Bootstrap Cloud data
%
% This method resamples (with replacement) the data stored in a Cloud.
%    >> object=bootstrap(object);
% The Moments and Correlations properties are updated to match the
% resampled object.
% 
% The default size of the output cloud is the same as the input cloud.
% This can be changed by passing a second input.
%    >> object=bootstrap(object,numpoints);
%
% 
% See also Cloud
%

%
% created August 6, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=bootstrap(object,numpoints)

% handle input
if (nargin<2) || isempty(numpoints)
    numpoints=object.NumberPoints;
end

index=randi(object.NumberPoints,[numpoints 1]);
object.Data=object.Data(index,:);
[moments,correlations]=summarize(object);
object.Moments=moments;
object.Correlations=correlations;
object.Source='bootstrap';

end