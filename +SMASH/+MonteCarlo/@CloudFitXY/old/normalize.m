function [object,corrections]=normalize(object)

xmin=+inf;
xmax=-inf;
ymin=+inf;
ymax=-inf;

N=numel(object.Cloud);
assert(N>1,'ERROR: insufficient data for normalization');
for n=1:N
    x=object.Cloud{n}.Moments(1,1);
    xmin=min(xmin,x);
    xmax=max(xmax,x);
    y=object.Cloud{n}.Moments(2,1);
    ymin=min(ymin,y);
    ymax=max(ymax,y);
end

Lx=xmax-xmin;
Ly=ymax-ymin;
for n=1:N
    data=object.Cloud{n}.Data;
    data(:,1)=data(:,1)-xmin;
    if Lx~=0
        data(:,1)=data(:,1)/Lx;
    end
    data(:,2)=data(:,2)-ymin;
    if Ly~=0
        data(:,2)=data(:,2)/Ly;
    end
    object.Cloud{n}.Data=data;
end

corrections.xmin=xmin;
corrections.Lx=Lx;
corrections.ymin=ymin;
corrections.Ly=Ly;

end