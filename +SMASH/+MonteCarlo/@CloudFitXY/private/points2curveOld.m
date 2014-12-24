% points2curve Determine shortest distaces from a set of points to a curve
%
% This function ...
%     >> [L2,nearest]=points2curve(points,curve);
%     >> points2curve('exampleA');
function varargout=points2curve(varargin)

% handle input
if nargin==0
    points2curve('exampleA');
    return;
elseif (nargin==1) && ischar(varargin{1})
    points=rand(100,2);
    switch varargin{1}
        case 'exampleA'
            x=linspace(0,1,5);
            y=x.^2;
        case 'exampleB'
            t=linspace(0,2*pi,50);
            x=(1+0.5*cos(t))/2;
            y=(1+sin(t))/2;   
        case 'exampleC'
            x=[0 0.5 0.5 0.5 1];
            y=[0 0.3 nan 0.6 1];
        otherwise
            error('ERROR: invalid example');
    end
    curve=[x(:) y(:)];
    fprintf('Running %s\n',varargin{1});
elseif (nargin==2) && (isnumeric(varargin{1})) && (isnumeric(varargin{2}))
    points=varargin{1};
    curve=varargin{2};
else
    error('ERROR: invalid input');
end

% error checking
[Npoints,Ncolumn]=size(points);
assert(Ncolumn==2,'ERROR: invalid points array');
x=reshape(points(:,1),[1 Npoints]); 
y=reshape(points(:,2),[1 Npoints]);

[Ncurve,Ncolumn]=size(curve);
assert(Ncolumn==2,'ERROR: invalid curve array');
p=reshape(curve(:,1),[1 Ncurve]);
q=reshape(curve(:,2),[1 Ncurve]);

% prepare storage arrays
L2min=inf(1,Npoints);
nearest=nan(2,Npoints);
pnear=nan(1,Npoints);
qnear=nan(1,Npoints);

% step through curve segments
for m=1:(Ncurve-1)
    if any(isnan([p(m:m+1) q(m:m+1)]))
        continue
    end
    % initial point test
    pnear(1:end)=p(m); % column array
    qnear(1:end)=q(m); % column array
    L2=(x-pnear).^2+(y-qnear).^2;
    [L2min,index]=min([L2min; L2]);
    keep=(index==2);
    nearest(:,keep)=[pnear(keep); qnear(keep)];
    % final point test
    pnear(1:end)=p(m+1); % column array
    qnear(1:end)=q(m+1); % column array
    L2=(x-pnear).^2+(y-qnear).^2;
    [L2min,index]=min([L2min; L2]);
    keep=(index==2);
    nearest(:,keep)=[pnear(keep); qnear(keep)];
    % intermediate point test (orthogonal projection)
    ux=p(m+1)-p(m); % scalar
    uy=q(m+1)-q(m); % scalar
    vx=x-p(m); % column array
    vy=y-q(m); % column array
    gamma=(ux*vx+uy*vy)/(ux.*ux+uy.*uy); % column array
    keep=(gamma>=0) & (gamma<=1);   
    pnear(keep)=p(m)+gamma(keep).*ux;
    qnear(keep)=q(m)+gamma(keep).*uy;
    L2(keep)=(x(keep)-pnear(keep)).^2+(y(keep)-qnear(keep)).^2;
    L2(~keep)=inf;
    [L2min,index]=min([L2min; L2]);
    keep=(index==2);
    nearest(:,keep)=[pnear(keep); qnear(keep)];
end

% handle output
if nargout==0
    figure;
    plot(points(:,1),points(:,2),'o',curve(:,1),curve(:,2),'-sq');
    for n=1:Npoints
        xc=[x(n) nearest(1,n)];
        yc=[y(n) nearest(2,n)];
        line(xc,yc);
        axis equal;
        axis square;
    end
else
    varargout{1}=L2min;
    varargout{2}=transpose(nearest);
end

end