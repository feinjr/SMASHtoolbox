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
 area=cumtrapz(time,amplitude);
 
 assert(duration < (time(end)-time(1)),...
     'ERROR: crossing duration is too large');
 
 % 
 T=object.SamplePeriod;
 skip=ceil(duration/(2*T));
 if rem(skip,2)==1
     skip=skip+1;
 end
 
% process local data 
location=nan(object.MaxCrossings,1);
for m=1:object.MaxCrossings
    % identify cross region
    [~,index]=max(amplitude);
    left=abs(area(index)-area(index-skip));
    right=abs(area(index)-area(index+skip));
    if left > right
        left=index-skip/2;
        right=index;
    else
        left=index;
        right=index+skip/2;
    end
    temp=left:right;
    [~,index]=min(amplitude(temp));
    center=time(temp(index));
    keep=(abs(time-center) <= (duration/2));    
    tm=time(keep);
    xm=x(keep);
    ym=y(keep);
    Am=amplitude(keep);      
    weight=Am/trapz(tm,Am);
    % select best starting point       
    tspan=tm(end)-tm(1);          
    ti=-(duration/2):T:(duration/2);
    keep=(abs(tm-center) < duration/4);
    tmk=tm(keep);    
    temp=nan(size(tmk));
    for k=1:numel(tmk)
        temp(k)=residual(tmk(k),'direct');
    end    
    [~,index]=min(temp);
    guess=tmk(index);
    % optimize result
    ti=-(duration/2):(T/5):(duration/2);
    result=fminsearch(@residual,0,...
        optimset('TolX',1e-9));%'Display','iter'));
    [~,location(m)]=residual(result);
    % remove cross region for next iteration
    amplitude(keep)=0;        
end

    function [chi2,t0]=residual(arg,mode)
        if nargin==1
            t0=guess+tspan/2*sin(arg);
        elseif strcmp(mode,'direct')
            t0=arg;
        end
        %fprintf('t0=%.4f\n',t0*1e12);
        xmA=interp1(tm-t0,xm,ti,'linear',0);
        xmB=interp1(tm-t0,xm,-ti,'linear',0);
        xerr=xmA-xmB;
        ymA=interp1(tm-t0,ym,ti,'linear',0);
        ymB=interp1(tm-t0,ym,-ti,'linear',0);
        yerr=ymA+ymB;
        w=interp1(tm-t0,weight,ti,'linear',0);
        w=w/sum(w);
        chi2=w.*(xerr.^2+yerr.^2);
        chi2=sum(chi2)/numel(chi2);
    end

location=sort(location);

end