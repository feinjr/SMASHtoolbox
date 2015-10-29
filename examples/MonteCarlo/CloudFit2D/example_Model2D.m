%% linear data
rng(20151028);

%Npoints=5;
Npoints=50;
%Npoints=5000;
x=linspace(0,1,Npoints);
x=x(:);
y=x;

dx=0.25;
x=x+dx*randn(Npoints,1);
dy=0.25;
y=y+dy*randn(Npoints,1);
data=[x y];

figure;
plot(x,y,'o');

fit=@(p,xb,yb) [xb(:) polyval(p,xb(:));]; % fancy way of representing two points on a straight line
object=SMASH.MonteCarlo.Support.Model2D(fit,[1 0]);

object=optimize(object,data,[],[dy*1e-6 dy 0]);
hl(1)=view(object.Curve,gca);

object=optimize(object,data,[],[dx dx*1e-6 0]);
hl(2)=view(object.Curve,gca);

object=optimize(object,data,[],[dx dy 0]);
hl(3)=view(object.Curve,gca);

LineStyle={'-','--',':'};
for n=1:3
    set(hl(n),'LineStyle',LineStyle{n});
end

legend(hl,'Vertical','Horizontal','Both','Location','northwest');

%% Gaussian peak
rng(20151029);

N=50;
x=linspace(-1,+1,N);
x=x(:);
y=exp(-x.^2/(2*0.25^2))+0.05*randn(size(x));
data=[x y];

figure;
plot(x,y,'.');

fit=@(p,xb,yb) [x p(1)+p(2)*exp(-(x-p(3)).^2/(2*p(4)^2))];
guess=nan(4,1);
guess(1)=min(y);
[guess(2),index]=max(y);
guess(2)=guess(2)-guess(1);
guess(3)=x(index);
guess(4)=(max(x)-min(x))/4;
object=SMASH.MonteCarlo.Support.Model2D(fit,guess);

%object.OptimizationSettings=optimset('Display','iter');
tic;
object=optimize(object,data,[],[1e-9 1 0]);
toc;
view(object.Curve,gca);