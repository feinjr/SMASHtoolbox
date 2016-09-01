% 
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
temp=object.Measurement;
FFToptions=struct('RemoveDC',true,'NumberFrequencies',1e6);
[f,P]=fft(temp,FFToptions);
[~,index]=max(P);
guess=f(index);
t=temp.Grid;
s=temp.Data;
s=s-mean(s);
f0=fminsearch(@DCpower,guess,optimset('TolX',1e-9));
    function P0neg=DCpower(fb)
        temp=reset(temp,[],s.*sin(2*pi*fb*t));
        P0neg=-mean(temp.Data)^2;
    end
object.ClockRate=f0;

period=1/f0;
object.ClockPeriod=period;

% find center pulse
t=object.Measurement.Grid;
first=t(1);
last=t(end);
T=(last-first)/(numel(t)-1);
center=(t(end)+t(1))/2;
local=crop(object.Measurement,center+[-2 +2]*period);

tau=period/10;
Dlocal=differentiate(local,[1 round(tau/T)]);
t=Dlocal.Grid;
s=Dlocal.Data;
[~,index]=max(s);
if t(index) < center
    left=t(index);
    right=left+period;
else
    right=t(index);
    left=right-period;
end

Dlocal=crop(Dlocal,[left right]);
t=Dlocal.Grid;
s=Dlocal.Data;
[~,index]=min(s);
boundary=t(index);

local=crop(local,[left right]);
A=std(local.Data(1:index));
B=std(local.Data(index:end));
if A > B
    center=(left+boundary)/2;
else
    center=(boundary+right)/2;
end

tc=[center:-period:first (center+period):period:last];
tc=sort(tc);
tc=tc(2:end-1);

% set up timing
object.PulseCenter=tc;
object.NumberPulses=numel(tc);
object.PulseBound(:,2)=tc+object.ClockPeriod/2;
object.PulseBound(:,1)=tc-object.ClockPeriod/2;

% record sampling
object.SamplePeriod=T;
object.SampleRate=1/T;

end