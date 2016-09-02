% locate Locate optical crossings within a pulse
%
% UNDER CONSTRUCTION
%

function location=locate(object,duration,pulse)

% manage input
assert(nargin >= 2,'ERROR: crossing duration is required');
assert(SMASH.General.testNumber(duration,'positive','notzero'),...
    'ERROR: invalid crossing duration');
assert(duration > 3*object.SamplePeriod,...
    'ERROR: crossing duration is too small');

if (nargin<3) || isempty(pulse)
    pulse=1;
elseif strcmpi(pulse,'all')
    pulse=1:object.NumberPulses;
end
assert(isnumeric(pulse),'ERROR: invalid pulse request');
Npulse=numel(pulse);

% analyze requested pulse(s)
location=nan(object.MaxCrossings,Npulse);

if SMASH.System.isParallel
    parfor m=1:Npulse
        location(:,m)=findCross(object,duration,pulse(m));
    end
else
    for m=1:Npulse
        location(:,m)=findCross(object,duration,pulse(m));
    end
end

end

function location=findCross(object,duration,pulse)

% extract local data
try
    local=extract(object,pulse);
catch
    error('ERROR: invalid pulse request');
end

time=local.Grid;
shape=lookup(object.PulseShape,time,'extrap');
local=local-shape;

local=hilbert(local,object.HilbertCutoff);
z=local.Data;
amplitude=sqrt(real(z.*conj(z)));
phase=unwrap(atan2(imag(z),real(z)));

persistent temp
if isempty(temp)
    temp=SMASH.SignalAnalysis.Signal(time,amplitude);
else
    temp=reset(temp,time,amplitude);
end
L=round(duration/(2*object.SamplePeriod));
temp=smooth(temp,'mean',L);
amplitude=temp.Data;

assert(duration < (time(end)-time(1)),...
    'ERROR: crossing duration is too large');

% process local data
location=nan(object.MaxCrossings,1);
for m=1:object.MaxCrossings
    % identify cross region
    [~,index]=max(amplitude);   
    centerA=time(index);            
    % restrict data to cross region
    keep=(abs(time-centerA) <= (duration/2));
    tm=time(keep);
    zm=z(keep);
    Am=amplitude(keep);
    phim=phase(keep);
    centerA=analyzePhase(tm,phim,Am);
    % symmetry optimization
    %span=2*object.SamplePeriod;
    span=5*object.SamplePeriod;
    T=object.SamplePeriod/20;
    ts=(centerA-span):T:(centerA+span);
    err=symerr(ts,tm,zm);
    [~,index]=min(err);
    center=ts(index);
    % refine optimization
    %     k=index+(-4:4);
    %     tsn=ts(k);
    %     t0=ts(1);
    %     tau=ts(end)-t0;
    %     tsn=(tsn-t0)/tau;
    %     tsn=tsn(:);
    %     errn=err(k);
    %     errn=(errn-min(errn))/(max(errn)-min(errn));
    %     errn=errn(:);
    %     matrix=ones(numel(tsn),3);
    %     matrix(:,1)=tsn.^2;
    %     matrix(:,2)=tsn;
    %     param=matrix \ errn;
    %     solution=-param(2)/(2*param(1));
    %     center=t0+solution*tau;
    location(m)=center;
    % remove cross region for next iteration
    drop=(abs(time-center) <= (duration));
    amplitude(drop)=0;
end

location=sort(location);

end