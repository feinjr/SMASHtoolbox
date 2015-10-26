% orthogonalDistance Estimate distance between a curve and a set of points
%
% This function estimates the orthogonal (shortest) distance between a
% curve and a set of points, each specified by a two-column array.
%    >> L2=orthogonalDistance(curve,point);
% The first input specifies (x,y) points that define the curve in a
% piece-wise linear fashion.  The second input defines (p,q) points where
% orthongal distance is to be calculated.  The output array L2 is an
% estimate of the minimum square distance between each (p,q) point and the
% curve.
%
% Intersections between the points and the curve are returned as the second
% output.
%    >> [L2,intersect]=orthogonalDistance(...);
% 

%
% created August 26, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=orthogonalDistance(varargin)

% handle input
assert(nargin>0,'ERROR: insufficient input');
if (nargin==1) && strcmpi(varargin{1},'demo')
    x=linspace(0,1,5);
    y=x.^2;
    curve=[x(:) y(:)];
    p=linspace(0,1,10);
    q=zeros(size(p));
    p(end+1:end+5)=1;
    q(end+1:end+5)=linspace(0.1,0.8,5);
    point=[p(:) q(:)];
elseif (nargin==2) && isnumeric(varargin{1}) && isnumeric(varargin{2})
    curve=varargin{1};
    point=varargin{2};
else
    error('ERROR: invalid input');
end

assert(size(curve,2)==2 | size(curve,1)>=2,...
    'ERROR: invalid curve array');
assert(size(point,2)==2 | size(point,1)>=1,...
    'ERROR: invalid point array');

% prepare arrays
x=curve(1:end-1,1); % local origins
y=curve(1:end-1,2); % local origins
dx=diff(curve(:,1));
dy=diff(curve(:,2));
M=numel(x);

p=transpose(point(:,1));
q=transpose(point(:,2));
N=numel(p);

X=repmat(x,[1 N]);
Y=repmat(y,[1 N]);
DX=repmat(dx,[1 N]);
DY=repmat(dy,[1 N]);
P=repmat(p,[M 1]);
Q=repmat(q,[M 1]);

% look for local optima
gamma=((P-X).*DX+(Q-Y).*DY)./(DX.^2+DY.^2);
gamma(gamma<0)=0;
gamma(gamma>1)=1;
X=X+gamma.*DX;
Y=Y+gamma.*DY;

% determine shortest distances
L2=(X-P).^2+(Y-Q).^2;
[L2,index]=min(L2,[],1);
index=sub2ind([M N],index,1:N);
X=X(index);
Y=Y(index);
intersect=[X(:) Y(:)];

% handle output
if nargout==0
    figure;
    [xt,yt]=deal(nan(N,3));
    xt(:,1)=p;
    yt(:,1)=q;
    xt(:,2)=X(:);
    yt(:,2)=Y(:);
    xt=transpose(xt);
    yt=transpose(yt);
    plot(curve(:,1),curve(:,2),'k-',p,q,'or',xt,yt,'b');
    axis square;
    axis equal;
else
    varargout{1}=L2;
    varargout{2}=intersect;
end

end