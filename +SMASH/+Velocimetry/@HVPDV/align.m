function object=align(object,fbound)

% manage input
if (nargin<2) || isempty(fbound)
    fbound=[0 inf];
end
assert(isnumeric(fbound) && numel(fbound)==2,...
    'ERROR: invalid frequency bound');
fbound=sort(fbound);
assert(diff(fbound)>0,'ERROR: invalid frequency bound');

% determine base frequency
FFToptions=struct('RemoveDC',true,'NumberFrequencies',2e6,...
    'SpectrumType','complex');
[f,y]=fft(object.Measurement,FFToptions);
keep=(f>=fbound(1)) & (f<=fbound(2));
f=f(keep);
y=y(keep);
P=real(y.*conj(y));

[Pmax,index]=max(P);
threshold=Pmax*0.50;
left=index;
right=index;
while true
    done=true;
    if P(left) > threshold
        if left>=1
            left=left-1;
            done=false;
        end
    end       
    if P(right) > threshold
        if (right<=numel(f))            
            right=right+1;
            done=false;
        end
    end 
    if done
        break
    end    
end

fc=f(left:right);
w=P(left:right);
w=w/trapz(fc,w);
f0=trapz(fc,w.*fc);
object.ClockRate=f0;

%% phase analysis
phase=interp1(f,y,f0);
phase=atan2(imag(phase),real(phase));

t=object.Measurement.Grid;
temp=SMASH.SignalAnalysis.Signal(t,sin(2*pi*f0*t));
[f,y]=fft(temp,FFToptions);
phase0=interp1(f,y,f0);
phase0=atan2(imag(phase0),real(phase0));

% set up clock times
period=1/f0;
object.ClockPeriod=period;
Delta=phase-phase0;
%temp=SMASH.SignalAnalysis.Signal(t,sin(2*pi*f0*t+Delta));

nc=2*mean(t)/period+Delta/pi-0.5;
nc=round(nc);
tc=period*((nc+1/2)/2-Delta/(2*pi));
tc=tc:-period:t(1);
tc=tc(end:-1:1);
tc=[tc tc(end)+period:period:t(end)];
tc=tc(:);
tc=tc(2:end-1); % drop first and last pulses, which may be partials

object.PulseCenter=tc;
object.NumberPulses=numel(tc);
object.PulseBound(:,2)=tc+object.ClockPeriod/2;
object.PulseBound(:,1)=tc-object.ClockPeriod/2;

% record sampling
T=(t(end)-t(1))/(numel(t)-1);
object.SamplePeriod=T;
object.SampleRate=1/T;

end