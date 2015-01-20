function [x,y]=parabola2(param,x)

y=polyval([param(1) 0 0],x);

end