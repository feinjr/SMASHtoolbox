%% compare FFT approach with direct method
xm=10+2*randn(1e4,1);
tic;
[x1,w1]=SMASH.MonteCarlo.estimateDensity(xm);
toc;
[x2,w2]=SMASH.MonteCarlo.estimateDensityDirect(xm);

subplot(2,1,1);
plot(x1,w1,x2,w2);
xlabel('Value');
ylabel('Probability density');
legend('FFT','Direct');

err=max(abs(w1-w2))/max(w2);
label=sprintf('%d measurements, <%.1e error',numel(xm),err);
text('Units','normalized','Position',[1 1],...
    'HorizontalAlignment','right','VerticalAlignment','bottom',...
    'String',label);

%% time comparison
subplot(2,1,2);

M=round(logspace(0,6,20));
t1=nan(1,numel(M));
t2=t1;
for m=1:numel(M);
    xm=randn(M(m),1);
    tic;
    SMASH.MonteCarlo.estimateDensity(xm);
    t1(m)=toc;
    tic;
    SMASH.MonteCarlo.estimateDensityDirect(xm);
    t2(m)=toc;
end

plot(M,t1,M,t2);
xlabel('Number of measurments');
ylabel('Computation time (s)');
set(gca,'XScale','log','YScale','log');
%text('Units','normalized','Position',[1 1],...
%    'HorizontalAlignment','right','VerticalAlignment','bottom',...
%    'String','Direct/FFT ratio');
%line(xlim,repmat(1,[1 2]),'Color','k','LineStyle','--')
legend('FFT','Direct','Location','northwest');
