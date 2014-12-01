%

function object=interpolate(object,x)

% handle input
if (nargin<2) || isempty(x)
    x=object.Grid;
    dx=min(abs(diff(x)));
    x1=min(x);
    x2=max(x);
    N=ceil((x2-x1)/dx);
    x=linspace(x1,x2,N);   
end

y=interp1(object.Grid,object.Data,x,'linear');
object.Grid=x;
object.Data=y;

end