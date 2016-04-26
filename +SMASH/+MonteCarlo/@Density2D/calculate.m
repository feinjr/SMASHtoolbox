% calculate Calculate probability density
%
% This method calculates probability density for a set of two variables.
% These variables may be specified by a source Cloud or as a table of
% statistical properties.
%    object=calculate(object,source);
%    object=calculate(object,table,numpoints); % default numpoints is 1e6
% Statistical properties are specified as shown below 
%    table=[xmean ymean xvar yvar]; % means and variances with zero correlation
%    table=[xmean ymean xvar yvar xycorr]; % abs(correlation)<1
%    table=[xmean ymean xvar yvar xycorr xskew yskew]; % skewness
%    table=[xmean ymean xvar yvar xycorr xskew yskew xkurt ykurt]; % excess kurtosis
%
% By default, an Image object of the probability density is generated
% in scaled coordinates (u,v).  Running this method in "thrifty" mode
% suppresses the Image to conserve memory.
%    object=calculate(...,'thrifty');
%
% See also Density2D, SMASH.ImageAnalysis.Image
%

%
% created March 3, 2016 by Daniel Dolan  (Sandia National Laboratories)
%
function object=calculate(object,varargin)

% manage input
Narg=numel(varargin);
assert(Narg>=1,'ERROR: insufficient nput');

if isa(varargin{1},'SMASH.MonteCarlo.Cloud');
    source=varargin{1};
    assert(source.NumberVariables==2,...
        'ERROR: measurement cloud must have two variables');
elseif isnumeric(varargin{1})
    table=varargin{1};
    numpoints=1e6;
    if (Narg>1) && isnumeric(varargin{2})
        if ~isempty(varargin{2})
            numpoints=varargin{2};        
        end
        varargin=varargin([1 3:end]);
        Narg=numel(varargin);
    end
    source=createCloud2D(table,numpoints);
else
    error('ERROR: invalid input');
end

if (Narg<2) || isempty(varargin{2}) || strcmpi(varargin{2},'nothrifty')
    thrifty=false;
elseif strcmpi(varargin{2},'thrifty')
    thrifty=true;
end

% characterize original coordinates
data=source.Data;
object.Original.XDomain=[min(data(:,1)) max(data(:,1))];
object.Original.YDomain=[min(data(:,2)) max(data(:,2))];
object.Original.Mean=mean(data,1);

% singular value decompostion
data=bsxfun(@minus,data,object.Original.Mean);
[data,D,C]=svd(data,0);

object.Scaled.Mean=mean(data,1);
object.Scaled.Std=std(data,[],1);
object.Scaled.Var=var(data,[],1);

object.Matrix.Reverse=D*transpose(C); % (u,v) to (x,y)
Dinv=diag(1./diag(D));
object.Matrix.Forward=C*Dinv; % (x,y) to (u,v)

areaUV=1;
table=[1 0; 0 1]; % (u,v) plane
table=table*object.Matrix.Reverse; % (x,y) plane
table(:,3)=0;
areaXY=cross(table(1,:),table(2,:));
areaXY=abs(areaXY(3));
object.Matrix.Jacobian=areaUV/areaXY;

% estimate density
Npoints=size(data,1);
width=object.Scaled.Std/Npoints^(1/5); % Silverman's rule
width=width*object.SmoothFactor;
normgrid=cell(1,2);
table=nan(Npoints,2);
ku=cell(1,2);
N2=pow2(nextpow2(object.GridPoints));
for n=1:2
    span=max(abs(data(:,n)))+object.PadFactor*width(n);
    temp=linspace(-span,+span,object.GridPoints(n));
    normgrid{n}=temp(:);
    %
    bin1=temp(1);
    spacing=(temp(end)-temp(1))/(object.GridPoints(n)-1);
    temp=round((data(:,n)-bin1)/spacing)+1;
    temp(temp<1)=1;
    temp(temp>object.GridPoints(n))=object.GridPoints(n);
    table(:,n)=temp;
    %
    start=-N2(n)/2;
    stop=+N2(n)/2-1;
    temp=(start:stop)/(N2(n)*spacing);
    ku{n}=ifftshift(temp(:));
end
Q=accumarray(table,1,object.GridPoints); % simple binning
Q(N2(1),N2(2))=0; % zero padding

P=fftn(Q);
for n=1:2
    temp=exp(-2*pi^2*width(n)^2*ku{n}.^2);
    index=ones(1,2);
    index(n)=N2(n);
    temp=reshape(temp,index);
    index=N2;
    index(n)=1;
    temp=repmat(temp,index);
    P=P.*temp;
end
density=ifftn(P,'symmetric');
density=density(1:object.GridPoints(1),1:object.GridPoints(2));

threshold=max(density(:))*object.MinDensityFraction;
density(density<threshold)=threshold;

mass=trapz(normgrid{1},density);
mass=trapz(normgrid{2},mass);
density=density/mass;

temp=max(density(:));
object.Scaled.MaxDensity=temp;
object.Original.MaxDensity=temp*object.Matrix.Jacobian;
temp=temp*object.MinDensityFraction;
object.Scaled.MinDensity=temp;
object.Original.MinDensity=temp*object.Matrix.Jacobian;

% interpolating object
[u,v]=ndgrid(normgrid{1},normgrid{2});
object.Scaled.Lookup=griddedInterpolant(u,v,density,'linear','none');
object.Scaled.ubound=[u(1) u(end)];
object.Scaled.urange=u(end)-u(1);
object.Scaled.uinc=(u(end)-u(1))/object.GridPoints(1);
object.Scaled.vbound=[v(1) v(end)];
object.Scaled.vrange=v(end)-v(1);
object.Scaled.vinc=(v(end)-v(1))/object.GridPoints(2);

% density image
density=transpose(density);
if thrifty
    object.Scaled.Image=[];
else
    temp=SMASH.ImageAnalysis.Image(...
        normgrid{1},normgrid{2},density);
    temp.Grid1Label='u';
    temp.Grid2Label='v';
    temp.DataLabel='Density';
    temp.Name='Probability density';
    temp.GraphicOptions.Title='Probability density in scaled coordinates';
    object.Scaled.Image=temp;
end

% generate contours
fraction=object.ContourFraction;
level=object.Scaled.MaxDensity*fraction;
if isscalar(level)
    temp=repmat(level,[1 2]);
else
    temp=level;
end
Cmatrix=contourc(normgrid{1},normgrid{2},density,temp);
n=1;
while n<size(Cmatrix,2)
    temp=(Cmatrix(1,n)==level);
    temp=fraction(temp);
    Cmatrix(1,n)=temp(1);
    n=n+Cmatrix(2,n)+1;
end
object.Scaled.ContourMatrix=Cmatrix;

n=1;
while n<size(Cmatrix,2)
    N=Cmatrix(2,n);
    start=n+1;
    stop=start+N-1;
    index=start:stop;
    temp=Cmatrix(:,index);
    temp=transpose(temp);
    temp=temp*object.Matrix.Reverse;
    temp=bsxfun(@plus,temp,object.Original.Mean);
    temp=transpose(temp);
    Cmatrix(:,index)=temp;    
    n=n+Cmatrix(2,n)+1;
end
object.Original.ContourMatrix=Cmatrix;

end