classdef CurveFit2D
    %%
    properties
        XLabel = 'X' % Horizontal axes label (string)
        YLabel % Vertical axes label (string)
        AssumeNormal = false % Ignore non-normal density (logical)
        OptimizationSettings = optimset(); % Optimization parameters
    end
    properties (SetAccess=protected)
        NumberMeasurements = 0 % Number of measurements (integer)
        MeasurementDensity % Probability densities (cell array of structures)
        DensitySettings % Calculation settings for probability density (immutable structure)
        XDomain % Horizontal domain ([xmin xmax]) for all measurements
        YDomain % Vertical domain ([ymin ymax]) for all measurements
        Model % Model function handle
        Parameter % Model parameters
        Bound % Parameter bounds
        CurvePoints % Model evaluation points (two-column array)
        CurveSegments % Model segments (five-column array)
    end
    properties (SetAccess=protected) % eventually make hidden
        Slack % Model slack parameters       
        BoundType % Parameter bound type
    end
    %%
    methods (Hidden=true)
        function object=CurveFit2D(varargin)            
            if (nargin==1) && strcmpi(varargin{1},'-empty')
                return % provided for SDA restore
            end
            object=create(object,varargin{:});
        end
    end    
    %%
    methods (Access=protected)
        varargout=create(varargin);
        %varargout=max(varargin);
        varargout=evaluate(varargin);
    end
    %% allow saved objects to be restored from a SDA file
    methods (Static=true,Hidden=true)
        function object=restore(data)
            object=SMASH.MonteCarlo.CurveFit2D('-empty');
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
        function object=set.OptimizationSettings(object,value)
            try
                value=optimset(value);
            catch
                error('ERRO: invalid OptimizationSettings value');
            end
            object.OptimizationSettings=value;
        end
    end
end