% This class performs curve fitting for data with uncertainty in two
% directions....
%
% UNDER CONSTRUCTION



% Individual data points are represented by virtual cloud
% distributed about the nominal center.  This distribution is represented
% by statistical moment (mean, variance, skewness, and excess kurtosis) in
% (x,y) and correlation between each variable.
%
% Objects from this class can be created with or without data points.
%    >> object=CloudFitXY(); % empty object
% UNDER CONSTRUCTION...
%


%
% See also MonteCarlo, Cloud
%

%
% created ???? by Daniel Dolan (Sandia National Laboratories)
%
classdef Fit2D
    %%
    properties (SetAccess=protected)
        Measurement = {} % Cell array of Cloud objects
        NumberMeasurements = 0 % Number of Cloud objects
    end
    properties (SetAccess=protected) % PROTECT ME
        Processed = false % Processed measurement flags
        ProcessedResult = {} %                
    end    
    properties
        Iterations = 100 % Monte Carlo iterations
    end
    properties (SetAccess=protected)
        ModelSettings % Model settings
        OptimizationSettings % Optimization settings  
        DisplaySettings % Display settings (used by view method)
    end  
    properties

    end
    %%
    methods (Hidden=true)
        function object=Fit2D(varargin)
            if (nargin==1) && strcmp(varargin{1},'-empty')
                return
            end
            object=create(object,varargin{:});
        end
    end
    %%
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end    
    
end