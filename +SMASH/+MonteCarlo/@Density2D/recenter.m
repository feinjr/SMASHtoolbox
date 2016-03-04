% recenter density2D object
%
% draws new means by rejection sampling
% does NOT update contours
%
%    object=recenter(object,'normal');
%    object=recenter(object,'general');
%
% meant for class methods, not end users!

function [object,trials]=recenter(object,mode)

u0=object.Scaled.ubound(1);
Lu=object.Scaled.urange;
v0=object.Scaled.vbound(1);
Lv=object.Scaled.vrange;
Pmax=object.Scaled.MaxDensity;

uc=object.Scaled.Mean(1);
vc=object.Scaled.Mean(2);
ustd=object.Scaled.Std(1);
vstd=object.Scaled.Std(2);
uvar=object.Scaled.Var(1);
vvar=object.Scaled.Var(2);

trials=0;
while true % rejection sampling
    trials=trials+1;
    temp=rand(1,3);
    u=u0+Lu*temp(1);
    v=v0+Lv*temp(2);
    switch mode
        case 'general'
            P=object.Scaled.Lookup(u,v);  
        otherwise
            P=1/(2*pi*ustd*vstd)*exp(-(u-uc)^2/(2*uvar)-(v-vc)^2/(2*vvar));
    end
    if (temp(3) <= P/Pmax)
        break
    end
end

position=[u v];
object.Scaled.Mean=position;

position=position*object.Matrix.Reverse+object.Original.Mean;
object.Original.Mean=position;

end