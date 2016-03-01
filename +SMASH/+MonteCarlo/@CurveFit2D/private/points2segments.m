% function should be called from a try/catch block

% NEEDS SOME WORK!
function segment=points2segments(points)

start=points(1:end-1,:);
stop=points(2:end,:);
Nsegment=size(start,1);
segment=nan(Nsegment,5);
index=0;
for n=1:Nsegment    
    if any(isnan(start(n,:))) || any(isnan(stop(n,:)))
        continue
    elseif any(isinf(start(n,:))) && any(isinf(stop(n,:)))
        continue
    elseif any(isinf(start(n,:)))
        x0=stop(n,1);
        y0=stop(n,2);
        next=stop(n+1,:);
        ok= ~any(isnan(next) | isinf(next));
        assert(ok,'ERROR: invalid curve points');
        Lx=x0-next(1);
        Ly=y0-next(2);
        etamax=inf;
    elseif any(isinf(stop(n,:)))        
        x0=start(n,1);
        y0=start(n,2);
        next=start(n-1,:);
        ok=~any(isnan(next) | isinf(next));
        assert(ok,'ERROR: invalid curve points');
        Lx=x0-next(1);
        Ly=y0-next(2);
        etamax=inf;
    else
        x0=start(n,1);
        y0=start(n,2);
        Lx=stop(n,1)-x0;
        Ly=stop(n,2)-y0;
        etamax=1;
    end
    index=index+1;
    segment(index,:)=[x0 y0 Lx Ly etamax];
end

segment=segment(1:index,:);

end