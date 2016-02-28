% add Add measurement(s)
%
% This method adds measurements to an existing Measurement2D object.
% Individual measurements may be specified as two-dimensional Cloud objects
% or as a table of statisticcal properties.  These representations are
% converted to an approximate probability density around each measurement.
%
% object=add(object,cloud);
% object=add(object,cloud1,cloud2);
% object=add(object,table);
% object=add(object,table,numpoints);
% mix and match...


function object=add(object,varargin)

% manage input
assert(nargin>1,'ERROR: insufficient input');

source={};
isnormal=[];
while numel(varargin)>0
    if isa(varargin{1},'SMASH.MonteCarlo.Cloud')
        assert(varargin{1}.NumberVariabes==2,...
            'ERROR: measurement cloud must have two variables');
        source{end+1}=varargin{1}; %#ok<AGROW>
        isnormal(end+1)=false; %#ok<AGROW>
        varargin=varargin(2:end);
    elseif isnumeric(varargin{1})
        table=varargin{1};
        if (numel(varargin)>1) && isnumeric(varargin{2})
            numpoints=varargin{1};
            varargin=varargin(3:end);
        else
            numpoints=[];
            varargin=varargin(2:end);
        end
        for n=1:size(table,1)
            [new,temp]=SMASH.MonteCarlo.CurveFit2D.createCloud2D(...
                table(n,:),numpoints);
            source{end+1}=new; %#ok<AGROW>
            isnormal(end+1)=temp; %#ok<AGROW>
        end
    elseif ischar(varargin{1})
        break
    else
        error('ERROR: invalid input');
    end
end

% convert source cloud(s) to probability density
M=numel(source);
start=object.NumberMeasurements;
object.ProbabilityDensity{end+M}=[];
for m=1:M
    object.ProbabilityDensity{start+m}=convert(...
        source{m}.Data,object.DensityOptions);    
    object.ProbabilityDensity{end}.IsNormal=isnormal(m);
end
object.NumberMeasurements=start+M;

end

function result=convert(data,setting)

result=struct();

% convert from original to scaled coordinates
center=mean(data,1);
result.Original.Mean=center;
data=bsxfun(@minus,data,center);

[data,D,C]=svd(data,0);
result.Scaled.Mean=mean(data,1);
result.Scaled.Std=std(data,[],1);
result.Scaled.Var=var(data,[],1);
result.Matrix.Reverse=D*transpose(C); % (u,v) to (x,y)
Dinv=diag(1./diag(D));
result.Matrix.Forward=C*Dinv; % (x,y) to (u,v)

areaUV=1;
table=[1 0; 0 1]; % (u,v) plane
table=table*result.Matrix.Reverse;
table(:,3)=0;
areaXY=cross(table(1,:),table(2,:));
areaXY=abs(areaXY(3));
result.Matrix.Jacobian=areaUV/areaXY;

% estmate density
Npoints=size(data,1);
width=result.Scaled.Std/Npoints^(1/5); % Silverman's rule
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
threshold=max(density(:))*setting.MinDensityFactor;
density(density<threshold)=threshold;

mass=trapz(normgrid{1},density);
mass=trapz(normgrid{2},mass);
density=density/mass;

temp=max(density(:));
result.Scaled.MaxDensity=temp;
result.Original.MaxDensity=temp*result.Matrix.Jacobian;
temp=temp*setting.MinDensityFactor;
result.Scaled.MinDensity=temp;
result.Original.MinDensity=temp*result.Matrix.Jacobian;

% interpolating object
[u,v]=ndgrid(normgrid{1},normgrid{2});
result.Scaled.Lookup=griddedInterpolant(u,v,density,'linear','none');
result.Scaled.ubound=[u(1) u(end)];
result.Scaled.vbound=[v(1) v(end)];

% Image store removed to conserve memory
%temp=SMASH.ImageAnalysis.Image(...
%    normgrid{1},normgrid{2},density);
%temp.GraphicOptions.AspectRatio='equal';
%result.Scaled.Image=temp;

% density boundary
density=transpose(density);
threshold=max(density(:))*setting.ContourFraction;
temp=contourc(normgrid{1},normgrid{2},density,...
    [threshold threshold]);
temp=SMASH.Graphics.contours2lines(temp);
temp=temp{1};
result.Scaled.Boundary=temp;
temp=temp*result.Matrix.Reverse;
result.Original.Boundary=bsxfun(@plus,temp,result.Original.Mean);

% approximate mode locations (assumes single mode!)
[u,v]=meshgrid(normgrid{1},normgrid{2});
threshold=max(density(:))*0.95;
keep=(density>=threshold);
w=density(keep);
w=w/sum(w);
u0=sum(w.*u(keep));
v0=sum(w.*v(keep));
temp=[u0 v0];
result.Scaled.Mode=temp;
temp=temp*result.Matrix.Reverse;
result.Original.Mode=bsxfun(@plus,temp,result.Original.Mean);

end