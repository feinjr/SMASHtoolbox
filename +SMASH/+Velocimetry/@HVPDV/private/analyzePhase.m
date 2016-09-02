function [center,chirp]=analyzePhase(time,phase,amplitude)

% identify central region
weight=min(amplitude);
weight=(amplitude-weight)/(max(amplitude)-weight);
weight=weight(:);

span=3*pi;
[~,index]=max(weight);
phi=phase(index);
for start=index:-1:1
    if abs(phase(start)-phi) > (span/2)
        break
    end
end
for stop=index:numel(phase)
    if abs(phase(stop)-phi) > (span/2);
        break
    end
end

keep=start:stop;
t=time(keep);
phi=phase(keep);
w=weight(keep);

% normalize and fit central region
tref=t(1);
duration=t(end)-tref;
t=(t-tref)/duration;

param=polyfit(t,phi,6);

% find zero crossings
increment=pi/2;
theta=increment*ceil(min(phi)/increment);
theta=theta:increment:max(phi);

index=(abs(cos(theta)) > abs(sin(theta)));
oddSym=theta(index);
evenSym=theta(~index);

Nodd=numel(oddSym);
todd=nan(Nodd,1);
for n=1:Nodd
    try
        todd(n)=invertPolynomial(param,oddSym(n));
    catch
        % do nothing
    end
end
todd=todd(~isnan(todd));
todd=sort(todd);

Neven=numel(evenSym);
teven=nan(Neven,1);
for n=1:Neven
    try
        teven(n)=invertPolynomial(param,evenSym(n));
    catch
        % do nothing
    end
end
teven=teven(~isnan(teven));
teven=sort(teven);

% analyze crossings to find center
table=nan(0,2);
%[~,index]=max(w);
%[~,index]=min(abs(t(index)-todd));
[~,left]=min(abs(todd-0.5));
%temp=interp1(t,w,todd);
%[~,left]=max(temp);
right=left;
while true    
    try
        table(end+1,:)=[todd(left) todd(right)]; %#ok<AGROW>
    catch
        break
    end
    left=left-1;
    right=right+1;
end

left=find(teven < table(1,1),1,'last');
right=left+1;
while true
    try
        table(end+1,:)=[teven(left) teven(right)]; %#ok<AGROW>
    catch
        break
    end
    left=left-1;
    right=right+1;
end

w=interp1(t,w,table);
w=mean(w,2);
table=mean(table,2);
center=sum(w.*table)/sum(w);

% evaluate chirp at center
chirp=polyval(polyder(param),center);

% map results back to original time base
center=tref+center*duration;
chirp=chirp/duration;

end

function x=invertPolynomial(param,y0)

ref=zeros(size(param));
ref(end)=y0;
solution=roots(param-ref);

keep=(abs(angle(solution)) < 1e-12);
solution=real(solution(keep));
x=0;
count=0;
for n=1:numel(solution)
    if (solution(n) >=0 ) && (solution(n) <=1 )
        x=x+solution(n);
        count=count+1;
    end
end
x=x/count;

end