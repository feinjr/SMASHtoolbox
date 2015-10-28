% 
function object=calculateWeights(object)

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
weight=nan(object.NumberClouds,1);
for n=1:N
    table=object.CloudData{n}.Data;
    xmean=object.CloudData{n}.Moments(1,1);
    ymean=object.CloudData{n}.Moments(2,1);
    table(:,1)=(table(:,1)-xmean)/Lx;
    table(:,2)=(table(:,2)-ymean)/Ly;
    temp=svd(table);
    temp=sum(temp.^2);
    weight(object.ActiveClouds(n))=1/temp;
end

object.CloudWeights=weight/max(weight);

end