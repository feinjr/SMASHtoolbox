% This class supports two-dimensional curve fitting with unceratinty in both
% directions.  Fitting is applied to a set of (x,y) measurements
% represented by probability density distributions.  These measurements are
% used to optimize parameters is a user-defined model using the method of
% maximum likelihood.
%
% Parameters associated with probability density calculations are defined
% when a CurveFit2D object is created.
%    object=CurveFit2D(name,value,...)
% See the Density2D class for more information about density parameters.
% Density parameters cannot be changed after an object is created, but
% measurements can be added/removed and models may be defined/redefined at
% any time.
%
% See also SMASH.MonteCarlo, Density2D
%

%
% created March 8, 2016 by Daniel Dolan (Sandia National Laboratories)
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