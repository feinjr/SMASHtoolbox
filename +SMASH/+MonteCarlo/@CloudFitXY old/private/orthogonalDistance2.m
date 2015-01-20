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
% revised October 14, 2014 by Daniel Dolan
%
function varargout=orthogonalDistance2(varargin)

% handle input
assert(nargin>0,'ERROR: insufficient input');
if (nargin==1) && strcmpi(varargin{1},'demo')
    x=linspace(0,1,5);
    %y=x.^2;
    y=x.^4;
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
x=curve(:,1);
xA=x(1:end-1);
xB=x(2:end);
xcenter=(xA+xB)/2;
M=numel(xcenter);

y=curve(:,2);
yA=y(1:end-1);
yB=y(2:end);
ycenter=(yA+yB)/2;

p=point(:,1);
q=point(:,2);
N=numel(p);

%Xcenter=repmat(xcenter,[1 N]);
%Ycenter=repmat(ycenter,[1 N]);
%P=repmat(transpose(p),[M 1]);
%Q=repmat(transpose(q),[M 1]);

% estimate nearest curve points
Lx=bsxfun(@minus,xcenter,transpose(p));
Ly=bsxfun(@minus,ycenter,transpose(q));
L2=Lx.*Lx+Ly.*Ly;
%L2=Lx.^2+Ly.^2;
%L2=(Xcenter-P).^2+(Ycenter-Q).^2;
[~,index]=min(L2,[],1);
xnear=xcenter(index);
ynear=ycenter(index);

% refine nearest curve points
ux=xB(index)-xA(index);
uy=yB(index)-yA(index);

vx=point(:,1)-xnear;
vy=point(:,2)-ynear;
gamma=(ux.*vx+uy.*vy)./(ux.^2+uy.^2);
gamma(gamma<-0.5)=-0.5;
gamma(gamma>+0.5)=+0.5;

xnear=xnear+gamma.*ux;
ynear=ynear+gamma.*uy;

L2=(xnear-p).^2+(ynear-q).^2;

% handle output
if nargout==0
    figure;
    [xt,yt]=deal(nan(N,2));
    xt(:,1)=p;
    yt(:,1)=q;
    xt(:,2)=xnear;
    yt(:,2)=ynear;
    xt=transpose(xt);
    yt=transpose(yt);
    plot(x,y,'k-',p,q,'or',xt,yt,'b');
    axis square;
    axis equal;
else
    varargout{1}=L2;
    varargout{2}=[xnear ynear];
end

end