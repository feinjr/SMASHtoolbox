function showComplexFits(f,y,fit)

figure;

subplot(2,1,1);
plot(f,real(y),'r',f,real(fit),'k');

subplot(2,1,2);
plot(f,imag(y),'r',f,imag(fit),'k');

end