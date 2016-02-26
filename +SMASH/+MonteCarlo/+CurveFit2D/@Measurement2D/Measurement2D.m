classdef Measurement2D
    properties
        NumberMeasurements = 0 % Current number of measurements
        Density = {} % Cell array of Density2D objects
        XLabel = 'X' % Horizontal axes label
        YLabel = 'Y' % Vertical axes label
    end
    %%
    methods
        function object=set.XLabel(object,value)
            assert(ischar(value),'ERROR: invalid XLabel');
            object.XLabel=value;
        end
        function object=set.YLabel(object,value)
            assert(ischar(value),'ERROR: invalid YLabel');
            object.YLabel=value;
        end
    end
end