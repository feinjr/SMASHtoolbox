% createCloud2D Create two-dimensional data cloud
% 
% This function creates a two-dimensional data cloud from a table of
% statistical properties.
%    object=createCloud2D(table,numpoints);
% The first input is mandatory while the second is optional (default value
% is 1e6).
%
% Four values in the input table specify normally distributed data with no
% correlation
%    table=[xmean ymean xvar yvar]; % means and variances (latter > 0)
% Adding a fifth value specifies linear correlation
%    table=[xmean ymean xvar yvar xycorr]; % abs(correlation)<1
% Skewness and excess kurtosis, when specified, must be declared in pairs.
%    table=[xmean ymean xvar yvar xycorr xskew yskew];
%    table=[xmean ymean xvar yvar xycorr xskew yskew xkurt ykurt];
%
% The second output of this function indicates whether the cloud was
% created with any skewness or excess kurtosis.
%    [object,isnormal]=createCloud2D(...);
% While the finite size of the cloud cause nonzero skewness and/or
% kurtosis, the output "isnormal" indicates that the cloud was meant to be
% normally distributed.
%
% See also CurveFit2D
%

%
% created February 26, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function [object,isnormal]=createCloud2D(table,points)

% manage input
N=numel(table);
switch N
    case {4 5 7 9}
        table(N+1:9)=0;
    otherwise
        error('ERROR: unable to create 2D cloud from this input');
end
assert(all(table(3:4)>0),'ERROR: variances must be greater than zero');
assert((table(5)>-1) && (table(5)<1),...
    'ERROR: correlation must be between -1 and +1');

if (nargin<2) || isempty(points)
    points=1e6;
end
assert(isnumeric(points) && isscalar(points) && ...
    (points>0) && (points==round(points)),'ERROR: invalid number of points');

% create Cloud object
moments=nan(2,4);
correlations=eye(2,2);
moments(1,1)=table(1);
moments(2,1)=table(2);
moments(1,2)=table(3);
moments(2,2)=table(4);
correlations(1,2)=table(5);
correlations(2,1)=table(5);
moments(1,3)=table(6);
moments(2,3)=table(7);
moments(1,4)=table(8);
moments(2,4)=table(9);

object=SMASH.MonteCarlo.Cloud(moments,correlations,points);

% report normal status
if all(table(6:9)==0)
    isnormal=true;
else
    isnormal=false;
end

end