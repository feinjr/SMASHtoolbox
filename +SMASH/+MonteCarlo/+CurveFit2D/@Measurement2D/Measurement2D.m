% 
%
% density parameters defined at object creation (keeps all measurements
% consistent)

classdef Measurement2D
    properties
        XLabel = 'X' % Horizontal axes label (string)
        YLabel = 'Y' % Vertical axes label (string)
        GraphicOptions % Graphic options object
        AssumeNormal = true % Assume normal uncertainty distributions (logical)
        %AssumeNormal = false % Assume normal uncertainty distributions (logical)
    end
    properties (SetAccess=protected);
        NumberMeasurements = 0 % Current number of measurements (integer)
        ProbabilityDensity = {} % Density calculations (cell array of structures)       
        DensityOptions = struct() % Density options (structure) defined at object creation
    end
    %%
    methods (Hidden=true)
        function object=Measurement2D(varargin)
            if (nargin==1) && strcmpi(varargin{1},'-empty')
                return
            end
            object=create(object,varargin{:});
        end
    end
    %%
    methods (Access=protected)
        varargout=create(varargin);
    end
    %% allow saved objects to be restored from a SDA file
    methods (Static=true,Hidden=true)
        function object=restore(data)            
            object=SMASH.MonteCarlo.CurveFit2D.Measurment2D('-empty');            
            name=fieldnames(data);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=data.(name{n});
                end
            end            
        end
    end
    %%
    methods
        function object=set.XLabel(object,value)
            assert(ischar(value),'ERROR: invalid XLabel value');
            object.XLabel=value;
        end
        function object=set.YLabel(object,value)
            assert(ischar(value),'ERROR: invalid YLabel value');
            object.YLabel=value;
        end
        function object=set.AssumeNormal(object,value)
            assert(islogical(value),'ERROR: invalid AssumeNormal value');
            object.AssumeNormal=value;
        end
    end
end