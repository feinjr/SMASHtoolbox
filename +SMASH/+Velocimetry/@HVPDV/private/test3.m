function test3(shift)

%
if (nargin<1) || isempty(shift)
    shift=0;
end

%%
t=0:(1/80):10;
sA=sin(2*pi*t);
sB=cos(2*pi*t);
drop=(t < 2) | (t > 8);
sA(drop)=0;
sB(drop)=0;
subplot(4,1,1);
plot(t,sA,t,sB);

%%
N=numel(t);
T=(t(end)-t(1))/(N-1);
N2=pow2(nextpow2(N)+1);
f=[0:(N2/2) (-N2/2+1):-1]/(N2*T);

SA=fft(sA,N2);
SB=fft(sB,N2);
%shift=-1/4;
new=ifft(SA.*exp(-2i*pi*f*shift));
new=real(new);
tnew=(0:(N2-1))*T;
sB(N2)=0;

subplot(4,1,2);
plot(tnew,new,tnew,sB)

%%

err=new-sB;

subplot(4,1,3);
plot(tnew,err);

err=trapz(tnew,err.^2)/tnew(end);
title(sprintf('shift=%g, error = %g',shift,err));

%%
dt=linspace(-3,3,200);
err=nan(size(dt));
for n=1:numel(dt)
    temp=exp(-2i*pi*f*dt(n));
    temp=temp.*SA-SB;
    temp=real(temp.*conj(temp));
    err(n)=trapz(f,temp)/max(f);
end

subplot(4,1,4);
plot(dt,err);
