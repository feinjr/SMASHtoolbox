%% create object
clear all;
clear java;
rng(0); % seed random number generator for testing
%clc;

object=CloudDistance;

%% define cloud
x=-0.0574;
y=0.003901;
%x=[0.0 0.5 1.0 1.0 1.0 0.5];
%y=[0.0 0.0 0.0 0.5 0.9 1.0];
%x=x(1);
%y=y(1);
%x=x(end-1);
%y=y(end-1);

M=numel(x);
%N=1000;
%N=100;
%N=10;
N=1;
%sigma=0.05;
sigma=0;
X=repmat(x(:),[1 N])+sigma*randn(M,N);
Y=repmat(y(:),[1 N])+sigma*randn(M,N);

object.DataX=X;
object.DataY=Y;

%% define curve
xc=linspace(-0.1,1.1,100);
yc=xc.^2;
object.Curve=[xc(:) yc(:)];

%% define allowed directions
%u=[1 0];
theta=[0.1 179.9];
%theta=[89.9 90.1];
%theta=[45 180-45];
%theta=[85 95];
u=[cosd(theta(1)) sind(theta(1))];
u=repmat(u,[M 1]);
v=[cosd(theta(2)) sind(theta(2))];
%v=[-1 0];
v=repmat(v,[M 1]);
%defineLimitVectors(object,u,v);
object.VectorU=u;
object.VectorV=v;

%% 
tic;
calculate(object);
L2=object.Distance2;
time=toc;

%%
xint=object.XIntersection;
yint=object.YIntersection;
plot(xc,yc,'k-',x,y,'rx',X(:),Y(:),'.');
for k=1:numel(X)
    line([X(k) xint(k)],[Y(k) yint(k)]);
end
daspect(gca,[1 1 1]);
pbaspect(gca,[1 1 1]);
figure(gcf);

iteration=(numel(xc)-1)*numel(X);
fprintf('Total iterations = %g\n',iteration);
fprintf('Total time time (s) = %#.3g\n',time);
%fprintf('Time per iteration (s) = %g\n',time/iteration);