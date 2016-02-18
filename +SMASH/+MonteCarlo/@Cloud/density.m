% density Estimate probability density
% 
% This function estimates the probability density with a summation of local
% Gaussians centered on each cloud point.  
%    [...]=density(object);
% Density can be calculated for 1-2 cloud variables at a time.  If the
% cloud contains more than 2 variables, the user is prompted to select
% variables for the density calculation.  Specific variables can also be
% selected with a second input.
%    [...]=density(object,var1); % select one variable
%    [...]=density(object,[var1 var2]); % select two variables
%
% For 1D calculations, this method has two outputs.
%    [dgrid,value]=density(object,var1); % calculation
%    plot(dgrid,value); % visualization
% "dgrid" is an array of grid locations where density values are evaluated.
%
% For 2D calculations, this method has three outputs.
%    [dgrid1,dgrid2,value]=density(object,[var1 var2]); % calculation
%    imagesc(dgrid1,dgrid2,value); % visualization
%    contour(dgrid1,dgrid2,value); % alternate visualization
% "dgrid1" and "dgrid2" are arrays of grid locations wehre density values
% are evaluated.
%
% Density calculations are controlled by the GridPoints and SmoothFactor
% properties.  The modify these properties, use the configure method.
%
% See also Cloud, configure
%

%
% created February 16, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=density(object,variable)

%
% NOTE: this method *should* work for 3D calculations and higher, but there
% are some bugs to work out.  Also, memory restrictions start to become an
% issue.  For example, a 1000 x 1000 x 1000 density array requires ~7 GB of
% RAM.  I may return to this issue in the future, but for now only 1-2
% calculations are supported.   -Dan
%

% manage input
if (nargin<2) || isempty(variable)
    variable=selectVariables(object,2,'bound');
end
assert(numel(variable)<=2,'ERROR: too many variables');
valid=1:object.NumberVariables;
for k=1:numel(variable)
    assert(any(variable(k)==valid),'ERROR: invalid variable number');
end

% read data from object
data=object.Data(:,variable);
[Npoints,Ndim]=size(data);

GridPoints=object.GridPoints;
if isscalar(GridPoints)
    GridPoints=repmat(GridPoints,[1 object.NumberVariables]);
end
GridPoints=GridPoints(variable);

% SVD transformation
center=mean(data,1);
data=bsxfun(@minus,data,center);

[data,S,V]=svd(data,0);
Sinv=diag(1./diag(S));
Vt=transpose(V);

% create normalized grid(s)
normgrid=cell(1,Ndim);
spacing=nan(1,Ndim); % grid spacing
width=nan(1,Ndim); % kernel width 

for n=1:Ndim
    temp=std(data(:,n))/Npoints^(1/5); % Silverman's rule
    width(n)=temp*object.SmoothFactor;
    span=max(abs(data(:,n)))+5*width(n);
    temp=linspace(-span,span,GridPoints(n));
    normgrid{n}=temp(:);
    spacing(n)=(normgrid{n}(end)-normgrid{n}(1))/(object.GridPoints-1);    
end

% bin data
table=nan(Npoints,Ndim);
for n=1:Ndim
    temp=round((data(:,n)-normgrid{n}(1))/spacing(n))+1;
    temp(temp<1)=1;
    temp(temp>GridPoints(n))=GridPoints(n);
    table(:,n)=temp;
end

if Ndim==1
    L=[GridPoints 1];
else
    L=GridPoints;
end
Q=accumarray(table,1,L);

% estimate density
k=cell(1,Ndim);
N2=pow2(nextpow2(GridPoints));
last=cell(1,Ndim);
for n=1:Ndim;
    start=-N2(n)/2;
    stop=+N2(n)/2-1;
    temp=(start:stop)/(N2(n)*spacing(n));
    k{n}=ifftshift(temp(:));   
    last{n}=N2(n);
end
Q(last{:})=0; % zero padding

P=fftn(Q);
for n=1:Ndim
    temp=exp(-2*pi^2*width(n)^2*k{n}.^2);
    if Ndim>1
        index=ones(1,Ndim);
        index(n)=N2(n);
    else
        index=[N2(n) 1];
    end
    temp=reshape(temp,index);
    if Ndim>1
        index=repmat(N2(n),[1 Ndim]);
        index(n)=1;
        temp=repmat(temp,index);
    end  
    P=P.*temp;
end

weight=ifftn(P,'symmetric');
weight(weight<0)=0;
keep=cell(1:Ndim);
for n=1:Ndim
    keep{n}=1:GridPoints(n);
end
weight=weight(keep{:});

% map result back to original coordinates
source=cell(1,Ndim); % grid arrays
[source{:}]=ndgrid(normgrid{:});

table=nan(prod(GridPoints),Ndim);
for n=1:Ndim
    table(:,n)=source{n}(:);
end
table=table*S*Vt;
table=bsxfun(@plus,table,center);

start=min(table,[],1);
stop=max(table,[],1);
[dgrid,final]=deal(cell(1,Ndim));
for n=1:Ndim
    dgrid{n}=linspace(start(n),stop(n),GridPoints(n));
    dgrid{n}=dgrid{n}(:);
end
[final{:}]=ndgrid(dgrid{:});

table=nan(prod(GridPoints),Ndim);
for n=1:Ndim
    table(:,n)=final{n}(:);
end
table=bsxfun(@minus,table,center);
table=table*V*Sinv;

intermediate=cell(1,Ndim);
for n=1:Ndim
    intermediate{n}=reshape(table(:,n),size(final{n}));
end
weight=interpn(source{:},weight,intermediate{:});
% Jacobian optional because SVD is pure rotation and scaling (global)
weight(isnan(weight))=0;

% normalize density
mass=weight;
index=cell(1,Ndim);
for n=1:Ndim
    for m=1:Ndim
        if m==n
            index{m}=1:GridPoints(n);
        else
            index{m}=1;
        end
    end    
    mass=trapz(dgrid{n},mass);
end
weight=weight/mass;

% manage output
varargout=cell(1,Ndim+1);
varargout(1:Ndim)=dgrid;
varargout{end}=weight;

end