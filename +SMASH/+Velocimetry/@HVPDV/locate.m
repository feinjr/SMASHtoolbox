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
x=real(local.Data);
y=imag(local.Data);
amplitude=sqrt(x.^2+y.^2);
%area=cumtrapz(time,amplitude);

assert(duration < (time(end)-time(1)),...
    'ERROR: crossing duration is too large');

% process local data
location=nan(object.MaxCrossings,1);
for m=1:object.MaxCrossings
    % identify cross region
    [value,index]=max(amplitude);
    % what about area threshold?
    threshold=value*0.75;
    center=time(index);
    keep=abs(time-center) <= duration;
    tk=time(keep);
    Ak=amplitude(keep);
    keep=(Ak >= threshold);
    tk=tk(keep);
    center=(tk(1)+tk(end))/2;              
    % restrict data to cross region
    keep=(abs(time-center) <= (duration/2));
    tm=time(keep);
    zm=x(keep)+1i*y(keep);
    % optimize to the nearest sample point
    span=duration/4;
    T=object.SamplePeriod;
    ts=(center-span):T:(center+span);    
    err=symerr(ts,tm,zm);
    [~,index]=min(err);
    center=ts(index);    
    % refine optimization between sample points
    span=T;
    T=T/10;
    ts=(center-span):T:(center+span);
    err=symerr(ts); % uses previously defined data
    [~,index]=min(err);
    centerA=ts(index);
    k=index+(-3:3);
    ts=ts(k);
    t0=ts(1);
    tau=ts(end)-t0;
    ts=(ts-t0)/tau; 
    ts=ts(:);
    err=err(k);
    err=(err-min(err))/(max(err)-min(err));
    err=err(:);
    %param=polyfit(ts,err,2);
    matrix=ones(numel(ts),3);
    matrix(:,1)=ts.^2;
    matrix(:,2)=ts;
    param=matrix \ err;
    solution=-param(2)/(2*param(1));
    center=t0+solution*tau;       
    %center=ts(index);       
    location(m)=center;   
    % remove cross region for next iteration
    amplitude(keep)=0;
end

location=sort(location);

end