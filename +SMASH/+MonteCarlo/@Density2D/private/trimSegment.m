% trimSegment Trim line segment within specified bounds
%
% This function trims a line segment table [x1 y1; x2 y2] to a set of
% specified bounds.
%    table=trimSegment(table,xbound,ybound)
% Trimming is based on several possible conditions:
%    1.  If both ends of the segment are inside the bounding rectangle,
%    nothing needs to be done.
%    2.  If one end of the segment is inside and the other outside the
%    rectangle, the exterior point will be projected inward to the nearest
%    boundary.
%    3.  If both ends of the segment are outside the rectangle, an attempt
%    is made to project both onto the boundary.  If this is not possible,
%    the segment table is replaced with NaN values.
%

%
% created July 18, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=trimSegment(table,xbound,ybound)

% testing
if nargin==0
    xbound=[0 1];
    ybound=[0 1];
    figure;
    plot(...
        [xbound(1) xbound(2) xbound(2) xbound(1) xbound(1)],...
        [ybound(1) ybound(1) ybound(2) ybound(2) ybound(1)],'k');
    %
    table=rand(2,2);
    line(table(:,1),table(:,2),'Marker','o');
    table=trimSegment(table,xbound,ybound);
    line(table(:,1),table(:,2),'Color','r');    
    %
    table(1,:)=rand(1,2);
    table(2,:)=[-0.5 0.5];
        line(table(:,1),table(:,2),'Marker','x');
    table=trimSegment(table,xbound,ybound);
    line(table(:,1),table(:,2),'Color','r');    
    %
    table(1,:)=rand(1,2)+[2 0];
    table(2,:)=[-0.5 0.5];
        line(table(:,1),table(:,2),'Marker','sq');
    table=trimSegment(table,xbound,ybound);
    line(table(:,1),table(:,2),'Color','r');   
    %
    table(1,:)=[-1 1.1];
    table(2,:)=[2 1.1];    
    line(table(:,1),table(:,2),'Marker','sq');
    table=trimSegment(table,xbound,ybound);
    line(table(:,1),table(:,2),'Color','r');   
    %
    axis tight;
    return;    
end


valid=true;
n=[2 1];
for m=1:2   
    x0=table(m,1);
    y0=table(m,2);
    if (x0 >= xbound(1)) && (x0 <= xbound(2))...
            && (y0 >= ybound(1)) && (y0 <= ybound(2))
        continue % point already inside bound
    end
    Lx=table(n(m),1)-table(m,1);
    Ly=table(n(m),2)-table(m,2);
    %
    fixed=false;
    eta=(xbound-x0)/Lx;    
    eta=sort(eta);
    temp=y0+eta*Ly;
    for k=1:2
        if (temp(k) >= ybound(1)) && (temp(k) <= ybound(2))
            table(m,1)=x0+eta(k)*Lx;
            table(m,2)=temp(k);
            fixed=true;
            break
        end
    end
    if fixed
        continue
    end
    %
    eta=(ybound-y0)/Ly;
    eta=sort(eta);
    temp=x0+eta*Lx;
    for k=1:2
        if (temp(k) >= xbound(1)) && (temp(k) <= xbound(2))
            table(m,1)=temp(k);
            table(m,2)=y0+eta(k)*Ly;
            fixed=true;
            break
        end
    end
    if ~fixed
        valid=false;
        break
    end    
end

if ~valid
    table=nan(1,4);    
end

% manage output
if nargout==0
    figure;
    plot(...
        [xbound(1) xbound(2) xbound(2) xbound(1) xbound(1)],...
        [ybound(1) ybound(1) ybound(2) ybound(2) ybound(1)]);
    line(table(:,1),table(:,2),'Marker','o');
else
    varargout{1}=table;
end

end