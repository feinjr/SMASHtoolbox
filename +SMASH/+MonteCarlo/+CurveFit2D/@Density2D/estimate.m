% estimate Estimate probability density
%
% This method estimates two-dimensional density from an existing data cloud
% or a table of statistical values.  It is automatically called at object
% creation and can be reused as necessary.
%    object=generate(object,source); % source cloud
%    object=Density2D(object,table,numpoints); % statistical table (see createCloud2D function)
%
% Settings for the density estimate can be specified by name/value pairs.
%    object=generate(...,name,value,...);
%    'GridPpoints'  : Grid points (1-2 integers) in evaluation region (default is 100)
%    'SmoothFactor' : Smoothing factor (>0) in Gaussin kernel (default is 2)
%    'PadFactor'    : Boundary padding factor (>0) for evaluation region (default is 5)
%    'ContourThreshold' : 
%    'DensityThreshold' :
%
% See also Density2D, createCloud2D
%

%
% created ?
%
function object=estimate(object,source,varargin)

% manage input
assert(nargin>1,'ERROR: insufficient input');
if isnumeric(source)
    if (nargin>2) && isnumeric(varargin{1})
        source=SMASH.MonteCarlo.CurveFit2D.createCloud2D(source,varargin{1});
        varargin=varargin(2:end);
    else
        source=SMASH.MonteCarlo.CurveFit2D.createCloud2D(source);
    end
end
assert(isa(source,'SMASH.MonteCarlo.Cloud'),'ERROR: invalid density source');
assert(source.NumberVariables==2,'ERROR: source cloud must have two variables');

setting=struct();
setting.IsNormal=false;
setting.GridPoints=[100 100];
setting.SmoothFactor=2;
setting.PadFactor=5;
setting.ContourThreshold=0.50; % relative
setting.DensityThreshold=1e-9; % relative
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid name');
    value=varargin{n+1};
    switch lower(name)
        case 'isnormal'
            assert(islogical(value) && isscalar(value),...
                'ERROR: invalid IsNormal value');
            setting.IsNormal=value;
        case 'gridpoints'   
            assert(isnumeric(value),'ERROR: invalid GridPoints value');
            if isscalar(value)
                value=repmat(value,[1 2]);
            end
            assert(numel(value)==2,'ERROR: invalid GridPoints value');
            assert(all(value>3) && all(value==round(value)),...
                'ERROR: invalid GridPoints value');
            setting.GridPoints=value;
        case 'smoothfactor'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid SmoothFactor value');
            setting.SmoothFactor=value;
        case 'padfactor'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid PadFactor value');
            setting.PadFactor=value;
        case 'contourthreshold'
            assert(isnumeric(value) && isscalar(value) && (value>0) && (value<1),...
                'ERROR: invalid ContourThreshold value');
            setting.ContourThreshold=value;
        case 'densitythreshold'
            ssert(isnumeric(value) && isscalar(value) && (value>0) && (value<1),...
                'ERROR: invalid DensityThreshold value');
            setting.DensityThreshold=value;
        otherwise
            error('ERROR: invalid setting name');
    end
end
object.Setting=setting;

% calculate density
data=source.Data;
Npoints=size(data,1);
center=mean(data,1);
object.Original.Mean=center;
data=bsxfun(@minus,data,center);

[data,D,C]=svd(data,0);
object.Final.Mean=mean(data,1);
object.Final.Std=std(data,[],1);
object.Final.Var=var(data,[],1);
object.Matrix.Reverse=D*transpose(C); % (u,v) to (x,y)
Dinv=diag(1./diag(D));
object.Matrix.Forward=C*Dinv; % (x,y) to (u,v)

width=object.Final.Std/Npoints^(1/5); % Silverman's rule
width=width*setting.SmoothFactor;
normgrid=cell(1,2);
table=nan(Npoints,2);
ku=cell(1,2);
N2=pow2(nextpow2(setting.GridPoints));
for n=1:2
    span=max(abs(data(:,n)))+setting.PadFactor*width(n);
    temp=linspace(-span,+span,setting.GridPoints(n));
    normgrid{n}=temp(:);
    %
    bin1=temp(1);
    spacing=(temp(end)-temp(1))/(setting.GridPoints(n)-1);
    temp=round((data(:,n)-bin1)/spacing)+1;
    temp(temp<1)=1;
    temp(temp>setting.GridPoints(n))=setting.GridPoints(n);
    table(:,n)=temp;
    %
    start=-N2(n)/2;
    stop=+N2(n)/2-1;
    temp=(start:stop)/(N2(n)*spacing);
    ku{n}=ifftshift(temp(:));
end
Q=accumarray(table,1,setting.GridPoints); % simple binning  
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
density=density(1:setting.GridPoints(1),1:setting.GridPoints(2));
threshold=max(density(:))*setting.DensityThreshold;
density(density<threshold)=threshold;
setting.Final.DensityThreshold=threshold;

mass=trapz(normgrid{1},density);
mass=trapz(normgrid{2},mass);
density=density/mass;

% interpolating object
[u,v]=ndgrid(normgrid{1},normgrid{2});
object.Final.Lookup=griddedInterpolant(u,v,density,'linear','none');

% density image and boundary
density=transpose(density);
%temp=SMASH.ImageAnalysis.Image(...
%    normgrid{1},normgrid{2},density);
%temp.GraphicOptions.AspectRatio='equal';
%object.Final.Image=temp;

threshold=max(density(:))*setting.ContourThreshold;
temp=contourc(normgrid{1},normgrid{2},density,...
    [threshold threshold]);
temp=SMASH.Graphics.contours2lines(temp);
temp=temp{1};
object.Final.Boundary=temp;
temp=temp*object.Matrix.Reverse;
object.Original.Boundary=bsxfun(@plus,temp,object.Original.Mean);

% approximate mode locations (assumes single mode!)
[u,v]=meshgrid(normgrid{1},normgrid{2});
threshold=max(density(:))*0.95;
keep=(density>=threshold);
w=density(keep);
w=w/sum(w);
u0=sum(w.*u(keep));
v0=sum(w.*v(keep));
temp=[u0 v0];
object.Final.Mode=temp;
temp=temp*object.Matrix.Reverse;
object.Original.Mode=bsxfun(@plus,temp,object.Original.Mean);

% calculate Jacobian
temp=object.Original.Boundary;
areaXY=polyarea(temp(:,1),temp(:,2));
temp=object.Final.Boundary;
areaUV=polyarea(temp(:,1),temp(:,2));

object.Jacobian=areaUV/areaXY;

end