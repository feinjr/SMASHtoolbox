% simulate(object,tmax);
%
% [t,x,v]=simulate(object,tmax);

function varargout=simulate(object,tmax,options)

% manage input
assert(nargin>=2,'ERROR: maximum time not specified');
assert(testValue(tmax),'ERROR: invalid maximum time');
assert(tmax>0,'ERROR: invalid maximum time');

if (nargin<3) || isempty(options)
    options=odeset();
end

y0=[object.InitialPosition object.InitialVelocity];
[time,y]=ode45(@(t,y) calculateDerivatives(object,t,y),...
    [0 tmax],y0,options);
position=y(:,1);
velocity=y(:,2);

% manage output
if nargout==0
    figure;  
    h=plotyy(time,position,time,velocity);
    xlabel(h(1),'Time');
    ylabel(h(1),'Position');
    ylabel(h(2),'Velocity');
    position=get(h(1),'Position');
    position(1)=0.15;
    position(2)=0.15;
    position(3)=1-2*position(1);
    position(4)=1-position(2)-0.05;
    set(h,'Position',position);
else
    varargout{1}=time;
    varargout{2}=position;
    varargout{3}=velocity;
end

end