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
% By default, updated moments and correlations are calculated from the
% bootrap results.  Faster bootstraps can be obtained if updated
% moment/correlation information is not required.
%      new=bootstrap(object,numpoints,'noupdate');
% 
% See also Cloud
%

%
% created August 6, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=bootstrap(object,numpoints,UpdateMode)

% handle input
if (nargin<2) || isempty(numpoints)
    numpoints=object.NumberPoints;    
end
%assert(numpoints>=10*object.NumberVariables,...
%    'ERROR: ERROR: at least 10 points per variable required');

if (nargin<3) || isempty(UpdateMode)
    UpdateMode='update';
end

index=randi(object.NumberPoints,[numpoints 1]);
object.Data=object.Data(index,:);
if strcmpi(UpdateMode,'update')
    [moments,correlations]=summarize(object);
    object.Moments=moments;
    object.Correlations=correlations;
end

object.Source='bootstrap';

end