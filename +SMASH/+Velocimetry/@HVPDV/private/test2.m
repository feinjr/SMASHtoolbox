%% this works
if false
    Fs = 800;
    Time_max = 4; % seconds
    t = 0:(1/Fs):Time_max;
    delay = 0.75; % One second of delay
    
    f = 5; %Hz
    y = sin(2 * pi * f * t);
    plot(t,y);
    y = [y, zeros(1,delay*Fs)];          % Zero-pad the signal by the amount of delay
    
    SIZE = 2^nextpow2(length(y));
    Y = fft(y,SIZE);
    
    T=(t(end)-t(1))/(numel(t)-1);
    f=[0:(SIZE/2) (-SIZE/2+1):-1]/(SIZE*T);
    
    %df = Fs/SIZE;
    %f= -Fs/2:df:Fs/2 - df;
    %%f=f(end:-1:1);
    
    %for k = 1:SIZE
    %    Y(k) = Y(k)*exp(-(1i*2*pi*f(k)*delay));
    %end
    Y=Y.*exp(-2i*pi*f*delay);
    
    td = (0:SIZE-1)/Fs;
    yd = real(ifft(Y));
    
    line(td,yd,'Color','k');
end

%% now this works!
N=1024;
%t=linspace(2,4,N);
t=linspace(0,2,N);
s=cos(2*pi*2*t);
s( (t<0.5) | (s>1.5))=0;
plot(t,s);
figure(gcf);
T=(t(end)-t(1))/(N-1);

N2=pow2(nextpow2(N)+1);
f=[0:(N2/2) (-N2/2+1):-1]/(N2*T);
S=fft(s,N2);

%shift=-1/2;
shift=1/2;
new=S.*exp(2i*pi*f*shift);
new=real(ifft(new));
tn=t(1)+(0:(N2-1))*T;

sp=s;
sp(N2)=0;

subplot(2,1,1);
h=plot(tn,sp,'g',tn,new,'k');
set(h(1),'LineWidth',2);

subplot(2,1,2);
plot(tn,sp-new);
err=trapz(tn,(sp-new).^2)/tn(end);
fprintf('error = %g\n',err);
