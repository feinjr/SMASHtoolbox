% estimateDensity Estimate probability density from a data table
%
% UNDER CONSTRUCTION
%

%
%
%
function varargout=estimateDensity(data,GridSize,SmoothFactor,level)

% manage input
assert(nargin>=1,'ERROR: insufficient input');
assert(all(isreal(data)),'ERROR: data table must be real');

assert(ismatrix(data),'ERROR: invalid data table');
if any(size(data))==1
    data=data(:);
end
[rows,cols]=size(data);
assert(cols<=2,...
    'ERROR: data table has too many columns (1-2 currently supported)');

if (nargin<2) || isempty(GridSize)
    GridSize=100;
end
assert(isnumeric(GridSize) && any(numel(GridSize)==[1 cols]),...
    'ERROR: invalid grid size');
if isscalar(GridSize)
    GridSize=repmat(GridSize,[1 cols]);
end
assert(all(GridSize>1) && all(GridSize==round(GridSize)),...
    'ERROR: invalid grid size');

if (nargin<3) || isempty(SmoothFactor)
    SmoothFactor=1;
end
assert(...
    isnumeric(SmoothFactor) && isscalar(SmoothFactor) && (SmoothFactor>0),...
    'ERROR: invalid smooth factor');

if (nargin<4) || isempty(level)
    level=3;
end
assert(isnumeric(level),'ERROR: invalid level value(s)');
if isscalar(level)
    assert((level>0) && (level==round(level)),...
        'ERROR: invalid number of levels');
    NumberLevels=level;
    level=linspace(0,1,NumberLevels+2);
    level=level(2:end-1); 
else
    NumberLevels=numel(level);
end
assert(all(level>0) && all(level<1),'ERROR: invalid level value(s)');
level=sort(level(:));

% SVD transformation
center=mean(data,1);
data=bsxfun(@minus,data,center);

[data,S,V]=svd(data,0);
Sinv=diag(1./diag(S));
Vinv=transpose(V);

% create normalized grid(s)
N2=pow2(nextpow2(GridSize));
width=nan(1,cols);
normgrid=cell(1,cols);
dngrid=nan(1,cols);
for n=1:cols
    width(n)=std(data(:,n))/rows^(1/5); % Silverman's rule
    width(n)=width(n)*SmoothFactor;
    span=5*width;
    normgrid{n}=linspace(-span,+span,N2(n));
    dngrid(n)=2*span/(N2(n)-1);
end

% bin data into a discrete array
table=nan(rows,cols);
for n=1:cols
    table(:,n)=round((data(:,n)-normgrid{n}(1))/dngrid(n))+1;
    index=(table(:,n)<1);
    table(index,n)=1;
    index=(table(:,n)>GridSize(n));
    table(index,n)=GridSize(n);
end
if cols==1
    Q=accumarray(table,1,[GridSize 1]);
else
    Q=accumarray(table,1,GridSize);
end

% estimate density
Qtransform=fftn(Q);
for n=1:cols
    start=-N2(n)/2;
    stop=+N2(n)/2;
    k=(start:stop)/(GridSize(n)*dngrid(n));
    Lk=ones(1,cols);
    Lk(n)=N2(n);
    k=reshape(k,Lk);
    Lk=Ngrid;
    Lk(n)=1;
    k=repmat(k,Lk);
    Qtransform=Qtransform.*exp(-2*pi^2*width(n)*k.^2);
end
weight=ifftn(Qtransform,'symmetric');
weight(weight<0)=0;

% boundary calculations
level=linspace(0,1,NumberLevels+2);
level=level(2:end-1);
switch cols
    case 1
        weight=weight/trapz(normgrid{1},weight);
        z=cumtrapz(normgrid{1},weight);
        LevelTable=nan(NumberLevels,2);
        for m=1:NumberLevels          
            LevelTable(m,:)=findBoundary(weight,level(m));
        end
    case 2        
        
end

% map results back to original coordinates

%index=[2 1 3:ndims(Q)];
%Q=permute(Q);

% manage output    
        
if nargout==0
    
else
    varargout{1}=grid;
    varargout{2}=weight;
end