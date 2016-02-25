function [D2,intersect]=calculateDistance(segments,points,matrix)

% setup variables
NumberSegments=size(segments,2);

NumberPoints=size(points,1);
D2=inf(NumberPoints,2); % second column is for temporary use
intersect=nan(NumberPoints,2);

a=matrix(1);
bc=matrix(2);
d=matrix(3);

% process segments
for m=1:NumberSegments   
    % extract segment parameters
    xref=segments(1,m);
    xinc=segments(2,m);
    yref=segments(3,m);
    yinc=segments(4,m);
    % find minimum distance locations (t: segment fraction variable)
    ux=xref-points(:,1);
    uy=yref-points(:,2);
    numerator=a*ux*xinc+bc*(ux*yinc+uy*xinc)+d*uy*yinc;
    denominator=a*xinc*xinc+2*bc*xinc*yinc+d*yinc*yinc;
    t=-numerator./denominator;
    if segments(5,m) % projection on side A
        % do nothing
    else
        t(t<0)=0;
    end
    if segments(6,m) % projection on side B
        % do nothing
    else
        t(t>1)=1;
    end        
    xt=xref+t*xinc;
    yt=yref+t*yinc;
    % determine nearest distances for current segment
    vx=xt-points(:,1);
    vy=yt-points(:,2);
    D2(:,2)=a*vx.*vx+2*bc*vx.*vy+d*vy.*vy;
    [D2(:,1),index]=min(D2,[],2);
    swap=(index==2);
    intersect(swap,1)=xt(swap);
    intersect(swap,2)=yt(swap);     
end
D2=D2(:,1); % remove temporary column

end