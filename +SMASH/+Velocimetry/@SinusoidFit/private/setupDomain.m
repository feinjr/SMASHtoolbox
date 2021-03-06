function [duration,slope]=setupDomain(boundary,time,width)

% locate boundary points
table=boundary.Data;
tb=table(:,1);
keep=(tb > time(1)) & (tb < time(end));
tb=[time(1); table(keep,1); time(end)];
fb=interp1(table(:,1),table(:,2),tb,'linear','extrap');

% identify subdomains
left=1;
start=1;
N=numel(tb);
while true
    Nremain=N-start+1;
    if Nremain <= 2
        break
    end
    for stop=(start+2):N
        index=start:stop;
        Q=polyfit(tb(index),fb(index),1);
        err=abs(polyval(Q,tb(index))-fb(index));
        if any(err > width)
            left(end+1)=stop; %#ok<AGROW>
            start=stop;
            break
        end       
    end
    if stop<N
        continue
    else
        break
    end
end
right=left(2:end)-1;
right(end+1)=N;

left=tb(left);
right=tb(right);

duration=right-left;

% estimate slope in each domain
N=numel(left);
slope=nan(N,1);
for n=1:N
    index=(tb >= left(n)) & (tb <= right(n));
    Q=polyfit(tb(index),fb(index),1);
    slope(n)=Q(1);
end

end