function showComplexFits(f,y,fit)

figure;

ha(1)=subplot(2,1,1);
plot(f,real(y),'r',f,real(fit),'k');
yb1=ylim;

ha(2)=subplot(2,1,2);
plot(f,imag(y),'r',f,imag(fit),'k');
yb2=ylim;

linkaxes(ha,'xy');
yb(1)=min(yb1(1),yb2(1));
yb(2)=max(yb1(2),yb2(2));
ylim(yb);

end