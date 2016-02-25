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
    properties
        XLabel = 'X' % horizontal axes label
        YLabel = 'Y' % vertical axes label
    end
    properties (SetAccess=protected)
        Measurement = {} % Cell array of Cloud objects
        NumberMeasurements = 0 % Number of Cloud objects
        DensitySettings  % Probability density settings   
    end
    properties (SetAccess=protected) % PROTECT ME
        IsProcessed = [] % Processed measurement flags
        ProcessedData = {} %                
    end    
    properties
        Iterations = 100 % Monte Carlo iterations
    end
    properties (SetAccess=protected)
        OptimizationSettings % Optimization settings
        Model  = struct('Function',[],'Parameters',[],'Bounds',[],...
            'Slack',[],'SlackReference',[],'Curve',[]) %      
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
    %% property setters
    methods        
%         function object=set.OptimizationSettings(object,value)
%             try
%                 value=optimset(value);
%             catch
%                 error('ERROR: invalid optmization settings');                
%             end
%             object.OptimizationSettings=value;
%         end
    end
    
end