% should be hidden!
%
%    object=recenter(object,'normal');
%    object=recenter(object,'general');
%

function object=recenter(object,mode)

for m=1:object.NumberMeasurements
    object.MeasurementDensity{m}=recenter(...
        object.MeasurementDensity{m},mode);
end

end