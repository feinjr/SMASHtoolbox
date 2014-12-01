% add Add data points 
%
% This method adds one or more data points to a CloudFitXY object.  Data
% can be specified with a set of arrays.
%   >> object=add(average,variance,[correlation],[skewness],[kurtosis]);
% The first two arrays are mandatory.  The first array is a Mx2 array of
% (x,y) values, where each row represents average values for a specific
% data point.  The second array specifies the variance of each data point:
%    -A scalar indicates common variance in both directions for all points
%    -A 1x2 array indicates indicates common variances for all points
%    -A Mx2 array permits specific x and y variances for each data point.
% The correlation array can be:
%    -Empty to indicate zero x-y correlation on all points
%    -A scalar to indicate common x-y correlation on all points
%    -A Mx1 array to specifically define x-y correlation for each point
% The skewness and kurtosis arrays can be specified in the same fashion as
% the variance array (1x1, 1x2, or Mx2).
%
% One or more existing Cloud objects can be inserted directly into a
% CloudFitXY object.
%    >> object=add(object,cloud1,cloud2,...);
%
% Several important conventions are noted below.
%    -Variable width is specified by variance, which is the *square* of the
%    standard deviation.
%    -Skewness is normalized by variance to the 3/2 power and is theremore
%    dimensionless.
%    -Excess kurtosis is used here.  With the implicit scaling (variance to
%    the 2 power), the excess kurtosis is zero for a normal distribution.
%
% See also CloudFitXY, remove
%

%
% created October 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=add(object,varargin)

% handle input
assert(nargin>1,'ERROR: insufficient number inputs');
Narg=numel(varargin);

% Cloud input
if isa(varargin{1},'SMASH.MonteCarlo.Cloud')
    for k=1:Narg
        if varargin{k}.NumberPoints ~= object.CloudSize
            varargin{k}.NumberPoints=object.CloudSize;
            varargin{k}=generate(varargin{k});
        end
        object.Clouds{end+1}=varargin{k};                
        object.NumberClouds=object.NumberClouds+1;
        object.ActiveClouds(end+1)=true;
    end    
    return
end

% tabular input
assert(nargin>=2,'ERROR: insufficient input');

assert(isnumeric(varargin{1}) & size(varargin{1},2)==2,...
    'ERROR: invalid average array');
x=varargin{1}(:,1);
y=varargin{1}(:,2);
N=numel(x);

assert(isnumeric(varargin{2}) & size(varargin{1},2)==2,...
    'ERROR: invalid variance input');
if size(varargin{2},1)==1
    varargin{2}=repmat(varargin{2},[N 1]);
end
if size(varargin{2},2)==1
    varargin{2}=repmat(varargin{2},[1 2]);
end
assert(size(varargin{2},1)==N,'ERROR: invalid variance array size');
dx2=varargin{2}(:,1);
dy2=varargin{2}(:,2);

if (numel(varargin)<3) || isempty(varargin{3})
    varargin{3}=0;
end
if numel(varargin{3})==1
    varargin{3}=repmat(varargin{3},[N 1]);
end
assert(all(size(varargin{3})==[N 1]),'ERROR: invalid correlation array size');
correlation=varargin{3};

if (numel(varargin)<4) || isempty(varargin{4})
    varargin{4}=0;
end
if numel(varargin{4})==1
    varargin{4}=repmat(varargin{4},[N 2]);
elseif all(size(varargin{4})==[1 2])
    varargin{4}=repmat(varargin{4},[N 1]);
end
assert(all(size(varargin{4})==[N 2]),'ERROR: invalid skewness array size ');
xskew=varargin{4}(:,1);
yskew=varargin{4}(:,2);

if (numel(varargin)<5) || isempty(varargin{5})
    varargin{5}=0;
end
if numel(varargin{5})==1
    varargin{5}=repmat(varargin{5},[N 2]);
elseif all(size(varargin{5})==[1 2])
    varargin{5}=repmat(varargin{5},[N 1]);
end
assert(all(size(varargin{5})==[N 2]),'ERROR: invalid kurtosis array size ');
xkurt=varargin{5}(:,1);
ykurt=varargin{5}(:,2);

moments=nan(2,4);
C=[1 0; 0 1];
for k=1:N
    moments(1,:)=[x(k) dx2(k) xskew(k) xkurt(k)];
    moments(2,:)=[y(k) dy2(k) yskew(k) ykurt(k)];
    C(2:3)=correlation(k);
    temp=SMASH.MonteCarlo.Cloud(moments,C,object.CloudSize);
    object=add(object,temp);
end

end