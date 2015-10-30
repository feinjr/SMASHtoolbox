%% generate Gaussian peak
rng(20151029);

N=50;
x=linspace(-1,+1,N);
x=x(:);
y=exp(-x.^2/(2*0.25^2))+0.05*randn(size(x));
data=[x y];

figure;
plot(x,y,'.');

%%
fit=@(p,xb,yb) [x p(1)+p(2)*exp(-(x-p(3)).^2/(2*p(4)^2))];
guess=nan(4,1);
guess(1)=min(y);
[guess(2),index]=max(y);
guess(2)=guess(2)-guess(1);
guess(3)=x(index);
guess(4)=(max(x)-min(x))/4;
tic;
%object.OptimizationSettings=optimset('Display','iter');
object=SMASH.MonteCarlo.Support.Model2D(fit,guess);
toc;