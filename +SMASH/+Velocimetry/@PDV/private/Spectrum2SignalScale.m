function scale=Spectrum2SignalScale(object)

t=object.Grid;
dt=(max(t)-min(t))/(numel(t)-1);
tmax=object.Partition.Duration;
t=0:dt:tmax;

fmin=1/tmax; % single fringe
fmax=1/(8*dt); % 1/4 of Nyquist
f0=(fmin+fmax)/2;

s=cos(2*pi*f0*t);
new=reset(object,t,s);
new.FFToptions.FrequencyDomain='positive';
new.FFToptions.SpectrumType='power';
[f,P]=fft(new,new.FFToptions);

Pmax=interp1(f,P,f0,'linear');

scale=sqrt(1/Pmax);

end