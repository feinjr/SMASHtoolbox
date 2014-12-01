function [x,y]=parabola1(param,x)

y=polyval([param(1) 0 param(2)],x);

end