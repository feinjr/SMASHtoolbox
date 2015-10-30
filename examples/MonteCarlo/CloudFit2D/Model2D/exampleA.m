%% generate linear data
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

%%
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
