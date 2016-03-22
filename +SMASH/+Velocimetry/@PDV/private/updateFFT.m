function object=updateFFT(object)

% compare transform to boxcar transform
dt=object.SampleInterval;

t=0:dt:object.Measurement.Partition.Duration;
s=ones(size(t));
temp=SMASH.SignalAnalysis.Signal(t,s);

[f,P]=fft(temp,...
    'RemoveDC',false,...
    'FrequencyDomain','full',...
    'SpectrumType','power',...
    'Window',object.Measurement.FFToptions.Window);
P0window=interp1(f,P,0,'nearest');
object.Duration=t(end);

[f,P]=fft(temp,...
    'RemoveDC',false,...
    'FrequencyDomain','full',...
    'SpectrumType','power',...
    'Window','boxcar');
P0boxcar=interp1(f,P,0,'nearest');
object.EffectiveDuration=t(end)*sqrt(P0window/P0boxcar);

% determine domain scaling
object.DomainScaling=P0window/4;

% determine minimum half width
persistent solution
if isempty(solution)
    target=@(x) sqrt(2)*sin(x) - x;
    solution=fzero(target,[eps 2*pi]);
end
object.EffectiveWidth=solution/(pi*object.EffectiveDuration);