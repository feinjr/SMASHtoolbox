% This class performs curve fitting for (x,y) data with uncertainty in both
% directions.  Individual data points are represented by virtual cloud
% distributed about the nominal center.  This distribution is represented
% by statistical moment (mean, variance, skewness, and excess kurtosis) in
% (x,y) and correlation between each variable.
%
% Objects from this class can be created with or without data points.
%    >> object=CloudFitXY(); % empty object
% UNDER CONSTRUCTION...
%


%    >> object=CloudFitXY(....);
% The second statement can use any input syntax supported by the add method
% for this class.
%
% Data points can be added to and removed from the object at any time.
% Points can also be activated and deactivated as needed.  Curve fitting is
% performed with the "analyze" method.
%
% See also MonteCarlo, Cloud
%

%
% created October 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef CloudFitXY
    %%
    properties (SetAccess=protected)
        NumberClouds = 0 % Number of Cloud objects
        ActiveClouds = logical([]) % Logical array indicating active Clouds
        Clouds = {} % Cell array of Cloud objects        
    end
    end
    properties
        Function % Fit function handle or file name
        Parameter % Fit parameters
        Bounds % Fit parameter bounds
    end
    properties
        CloudSize = 100 % Maximum number of points per cloud
        DrawSize = 1 % Cloud points drawn during each iteration
        Iterations = 100 % Monte Carlo iterations
        XLabel = 'x' % Horizontal coordinate label
        YLabel = 'y' % Vertical coordinate label
        WeightFunction = 'RMS' % Cloud distance weighting function
        GraphicOptions % Graphic options
    end
    %%
    methods (Hidden=true)
        function object=CloudFitXY(varargin)
            if nargin>0
                object=setup(object,varargin{:});
            end
            if isempty(object.GraphicOptions)
                object.GraphicOptions=SMASH.General.GraphicOptions;
            end
        end
    end
    %% 
    methods (Static=true, Hidden=true)
        function object=restore(data)
            error('ERROR: restore method is not ready yet!');
        end
    end
    %% property setters
    methods
        function object=set.CloudSize(object,value)
            assert(SMASH.General.testNumber(value,'integer'),...
                'ERROR: invalid CloudSize setting');
            if value~=object.CloudSize
                object.CloudSize=value;
                object=regenerate(object);
            end
        end
        function object=set.Iterations(object,value)
            assert(SMASH.General.testNumber(value,'integer'),...
                'ERROR: invalid Iterations setting');
            object.Iterations=value;
        end
        function object=set.XLabel(object,value)
            assert(ischar(value),'ERROR: invalid XLabel setting');
            object.XLabel=value;
        end
        function object=set.YLabel(object,value)
            assert(ischar(value),'ERROR: invalid YLabel setting');
            object.YLabel=value;
        end        
        function object=set.WeightFunction(object,value)
            assert(ischar(value),'ERROR: invalid WeightFunction setting');
        end
    end
    
end