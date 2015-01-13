%% create object
clear all;
clear java;
rng(0); % seed random number generator for testing
%clc;

mode='fast';
%mode='standard';
switch mode
    case 'fast'
        object=CloudDistanceFast;
        label='(fast mode)';
    otherwise
        object=CloudDistance;
        label='(standard mode)';
end

total=tic;
%% define cloud
x=[0.0 0.5 1.0 1.0 1.0 0.5];
y=[0.0 0.0 0.0 0.5 0.9 1.0];

M=numel(x);
%N=1e4;
N=1000;
%N=100;
%N=10;
%N=1;
sigma=0.05;
%sigma=0;
X=repmat(x(:),[1 N])+sigma*randn(M,N);
Y=repmat(y(:),[1 N])+sigma*randn(M,N);

fprintf('Passing cloud data: ');
tic;
object.DataX=X;
object.DataY=Y;
toc;

%% define curve
xc=linspace(-0.1,1.1,100);
%xc=linspace(-0.1,1.1,10);
yc=xc.^2;
%yc(xc>0.5)=0.4;
%fprintf('Passing curve data: ');
table=[xc(:) yc(:)];
%tic;
object.Curve=table;
%toc;

%% define allowed directions
%theta=[0 180]; % degrees
%theta=[90 90];
%theta=[45 180-45];
theta=[85 95];
%theta=[89.9 90.1];
object.Bound=...
    [cosd(theta(1)) sind(theta(1)) cosd(theta(2)) sind(theta(2))];
%fprintf('Passing bound data: ');
%tic;
object.Bound=repmat(object.Bound,[M 1]);
%toc;

%% 
%tic;
calculate(object);
%time=toc;

%iteration=(numel(xc)-1)*numel(X);
%fprintf('Total iterations = %g\n',iteration);
%fprintf('Total loop time (s) = %#.3g %s\n',time,label);
%fprintf('Time per iteration (s) = %g\n',time/iteration);

%%
%fprintf('Retrieving intersection data: ');
%tic;
xint=object.XIntersection;
yint=object.YIntersection;
L2=object.Distance2;
%toc;
toc(total);
% plot(xc,yc,'k-',x,y,'rx',X(:),Y(:),'.');
% for k=1:numel(X)
%     line([X(k) xint(k)],[Y(k) yint(k)]);
% end
% daspect(gca,[1 1 1]);
% pbaspect(gca,[1 1 1]);
% figure(gcf);

