% UNDER CONSTRUCTION
%
% object=CurveFit2D();
% Density options set at creation
%

%
% created ??? by Daniel Dolan (Sandia National Laboratories)
%
classdef CurveFit2D
    %%
    properties
        XLabel = 'X' % Horizontal axes label (string)
        YLabel = 'Y' % Vertical axes label (string)
        AssumeNormal = false % Ignore non-normal density (logical)
        OptimizationSettings = optimset() % Optimization parameters
        GraphicOptions % Graphic options used by view method (structure)
        DomainPadding = 0.10 % Domain padding fraction
    end
    properties (SetAccess=protected)
        NumberMeasurements = 0 % Number of measurements (integer)
        MeasurementDensity % Probability densities (cell array of Density2D objects)
        DensitySettings % Density calculation settings (structure)        
        XDomain % Horizontal domain ([xmin xmax]) for all measurements
        YDomain % Vertical domain ([ymin ymax]) for all measurements
        Model % Model function (function handle or string)
        Parameter % Model parameters (one-column array)
        Bound % Parameter bounds (two-column array)
        CurvePoints % Model evaluation points (two-column array)      
    end
    properties (SetAccess=protected) % eventually make hidden
        Slack % Model slack parameters       
    end
    %%
    methods (Hidden=true)
        function object=CurveFit2D(varargin)            
            if (nargin==1) && strcmpi(varargin{1},'-empty')
                return % provided for SDA restore
            end
            object=create(object,varargin{:});          
        end
        varargout=recenter(varargin);
    end    
    %%
    methods (Access=protected, Hidden=true)
        varargout=create(varargin);   
    end
    %% allow saved objects to be restored from a SDA file
    methods (Static=true,Hidden=true)
        varargout=restore(varargin);
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
        function object=set.GraphicOptions(object,value)
            assert(isstruct(value),'ERROR: invalid GraphicOptions value');            
            if ~isempty(object.GraphicOptions)
                name=fieldnames(value);
                for n=1:numel(name)
                    assert(isfield(object.GraphicOptions,name{n}),...
                        'ERROR: unrecognized graphic option');
                end
            end
            object.GraphicOptions=value;
        end
    end
end