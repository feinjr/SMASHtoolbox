%%
figure;
N=1e4;
%q=SMASH.MonteCarlo.Cloud([0 1; 0 2],[],N);
%q=SMASH.MonteCarlo.Cloud([0 1; 0 4]);
%q=SMASH.MonteCarlo.Cloud([0 1; 0 25]);
q=SMASH.MonteCarlo.Cloud([0 1; 0 1],[1 0.5; 0.5 1],N);
hist(q);
hold on;

M=cov(q.Data);
[V,D]=eig(M);
Vc=D*V;

x=Vc(:,1);
y=Vc(:,2);
h=compass(x,y,'m');
set(h(end),'LineWidth',2);

u=[x(2)+x(1);x(2)-x(1)];
v=[y(2)+y(1);y(2)-y(1)];
compass(u,v,'k');
%compass(-u,-v,'k');

span=(D(1)/D(end))*90;
fprintf('span = %.1f degrees\n',span);