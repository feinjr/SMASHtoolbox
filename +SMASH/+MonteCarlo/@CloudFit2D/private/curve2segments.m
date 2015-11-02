function segments=curve2segments(curve)

wrapped=all(curve(1,:)==curve(end,:));

MaxSegments=size(curve,1)-1;
segments=nan(6,MaxSegments);
ValidSegments=0;
for m=1:MaxSegments
    % verify segment
    skip=isnan(curve(m:m+1,:));
    if any(skip)
        continue
    end
    % characterize segment
    ValidSegments=ValidSegments+1;
    xref=curve(m,1);
    xinc=curve(m+1,1)-xref;
    yref=curve(m,2);
    yinc=curve(m+1,2)-yref;
    % store results
    segments(1,m)=xref;
    segments(2,m)=xinc;
    segments(3,m)=yref;
    segments(4,m)=yinc;
    if (m==1) && (~wrapped)
        segments(5,m)=true;
    else
        segments(5,m)=false;
    end
    if (m==MaxSegments) && (~wrapped)
        segments(6,m)=true;
    else
        segments(6,m)=false;
    end    
end

segments=segments(:,1:ValidSegments);

end