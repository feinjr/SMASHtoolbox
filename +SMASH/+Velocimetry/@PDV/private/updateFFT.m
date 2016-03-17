function object=updateFFT(object)

% domain calibration
dt=object.SampleInterval;

t=0:dt:object.Measurement.Partition.Duration;
fmin=1/t(end); % single fringe
fmax=1/(8*dt); % 1/4 of Nyquist
f0=(fmin+fmax)/2;
s=cos(2*pi*f0*t);
temp=SMASH.SignalAnalysis.Signal(t,s);
[f,P]=fft(temp,...
    'RemoveDC',true,...
    'FrequencyDomain','positive',...
    'SpectrumType','power',...
    'NumberFrequencies',1e6,...
    'Window',object.Measurement.FFToptions.Window);
Pmax=interp1(f,P,f0,'linear');
object.DomainScaling=Pmax;

% calculate minimum width and equivalent duration
width=estimateWidth(f-f0,P/Pmax);
object.MinimumWidth=width;
object.Duration=t(end);

[f,P]=fft(temp,...
    'RemoveDC',true,...
    'FrequencyDomain','positive',...
    'SpectrumType','power',...
    'NumberFrequencies',1e6,...
    'Window','boxcar');
Pmax=interp1(f,P,f0,'linear');
width=estimateWidth(f-f0,P/Pmax);
object.BoxcarDuration=t(end)*(width/object.MinimumWidth);

end

function width=estimateWidth(f,P)

below=(P < 0.50);
left=find(below & (f<0),1,'last');
right=find(below & (f>0),1,'first');

width=(f(right)-f(left))/2;

end