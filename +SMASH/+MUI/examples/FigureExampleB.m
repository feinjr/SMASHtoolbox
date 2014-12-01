% two axes figure
% some toggle buttons require axes to be selected
fig=SMASH.MUI.Figure();
fig.Name='Double axes example';

subplot(2,1,1);
x=linspace(0,1,100);
y=cos(2*pi*5*x);
plot(x,y);

subplot(2,1,2);
X=reshape(x,[],numel(x));
X=repmat(X,[numel(x) 1]);
imagesc(X);
xlabel('X');
ylabel('Y');
hc=colorbar;
ylabel(hc,'Exposure');
