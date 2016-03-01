function result=analyze(object,iterations)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=100;
end

% determine draw regions

% parallelization?
center=draw(object);

end

% rejection sampling
function [center,iteration]=draw(object)

M=object.NumberMeasurements;
center=nan(M,2);

iteration=0;
for m=1:M;
    measurement=object.MeasurementDensity{m};    
    Pmax=measurement.Scaled.MaxDensity;    
    ubound=measurement.Scaled.ubound;
    u0=ubound(1);
    Lu=ubound(2)-ubound(1);    
    vbound=measurement.Scaled.vbound;
    v0=vbound(1);
    Lv=vbound(2)-vbound(1);
    while true
        iteration=iteration+1;
        temp=rand(1,3);
        pos=[u0 v0]+[Lu Lv].*temp(1:2);
        P=measurement.Scaled.Lookup(pos(1),pos(2));
        if (temp(3) <= P/Pmax)           
            break
        end
    end
    pos=pos*measurement.Matrix.Reverse;
    pos=pos+measurement.Original.Mode;
    center(m,:)=pos;
end
iteration=iteration/M; % average iterations per measurement

end