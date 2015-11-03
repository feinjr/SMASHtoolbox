% calculateWeights Determine cloud weights
%
% This method determines the relative weight for each cloud based on
% singular value decompostion.  It is called automatically in standard form:
%      object=calculateWeights(object);
% whenever clouds are added or removed.
% 
% Due to finite cloud size, weights of nominally similar clouds may appear
% to have different weighting.  To mitigate this issue, weight calculations
% may be refined using a bootstrap technique.
%     object=calculateWeights(object,iterations); % iterations=1 by default
% Additional iterations tend to stabilize cloud weights.  Since
% adding/removing clouds modifies weights automatically, refined weighting
% should be done after such changes are complete.
%
% See also CloudFit2D
%

%
% created November 2, 2015 by Daniel Dolan (Sandia National Laboratory)
%
function object=calculateWeights(object,iterations)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=1;
end

clouds=object.CloudData(object.ActiveClouds);
N=numel(clouds);

% determine characteristic scales
xb=[+inf -inf];
yb=[+inf -inf];
for n=1:N
    xmean=object.CloudData{n}.Moments(1,1);
    xb(1)=min(xb(1),xmean);
    xb(2)=max(xb(2),xmean);
    ymean=object.CloudData{n}.Moments(2,1);
    yb(1)=min(yb(1),ymean);
    yb(2)=max(yb(2),ymean);
end
Lx=xb(2)-xb(1);
Ly=yb(2)-yb(1);

% principle component analysis
weight=zeros(object.NumberClouds,1);
for k=1:iterations
    for n=1:N
        temp=bootstrap(object.CloudData{n},[],'noupdate');
        table=temp.Data;
        xmean=temp.Moments(1,1);
        ymean=temp.Moments(2,1);
        table(:,1)=(table(:,1)-xmean)/Lx;
        table(:,2)=(table(:,2)-ymean)/Ly;
        w=svd(table);
        w=1/sum(w.^2) + weight(object.ActiveClouds(n));
        weight(object.ActiveClouds(n))=w;
    end
end

object.CloudWeights=weight/max(weight);

end