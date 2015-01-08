%% create object
clear all;
clear java;
rng(0); % seed random number generator for testing
%clc;

object=CloudDistanceOld;

%% define cloud
x=[0.0 0.5 1.0 1.0 1.0 0.5];
y=[0.2 0.0 0.0 0.5 0.9 1.0];

M=numel(x);
%N=1000;
N=100;
%N=10;
sigma=0.05;
X=repmat(x(:),[1 N])+sigma*randn(M,N);
Y=repmat(y(:),[1 N])+sigma*randn(M,N);

defineCloud(object,X,Y);

%% define curve
xc=linspace(min(X(:))-0.1,max(X(:))+0.1,100);
yc=xc.^2;
defineCurve(object,xc,yc);


%% 
tic;
findNearestIntersection(object);
time=toc;
summarize(object);

L2=getDistance2(object);
xint=getXIntersect(object);
yint=getYIntersect(object);


plot(xc,yc,'k-',x,y,'rx',X(:),Y(:),'.');
for k=1:numel(X)
    line([X(k) xint(k)],[Y(k) yint(k)]);
end
daspect(gca,[1 1 1]);
pbaspect(gca,[1 1 1]);
figure(gcf);

iteration=(numel(xc)-1)*numel(X);
fprintf('Total iterations = %g\n',iteration);
fprintf('Total time time (s) = %g\n',time);
fprintf('Time per iteration (s) = %g\n',time/iteration);