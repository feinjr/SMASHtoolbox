%     >> object=LUNA(filename);

classdef LUNA
    properties
        SourceFile        
    end
    properties (SetAccess=protected)
        Measurement
    end
    methods (Hidden=true)
        function object=LUNA(filename)
            if nargin<1
                filename='';
            end
            object=read(object,filename);
        end
    end
end