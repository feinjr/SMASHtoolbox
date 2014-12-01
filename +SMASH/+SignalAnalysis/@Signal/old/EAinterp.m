% EAinterp : equal area interpolation
%
%    >> y2=EAinterp(x1,y1,x2);

% created October 2, 2013 by Daniel Dolan (Sandia National Laboratories)
function y2=EAinterp(x1,y1,x2)

area=cumtrapz(x1,y1);

L2=(x2(end)-x2(1))/(numel(x2)-1);
dx=L2/2;
xm=x2-dx;
xm(end+1)=xm(end)+L2;
xm=xm(:);
Am=interp1(x1,area,xm);

slope=(Am(2)-area(1))/dx;
Am(1)=Am(2)-slope*L2;
slope=(area(end)-Am(end-1))/dx;
Am(end)=Am(end-1)+slope*L2;

y2=diff(Am)/L2;

end