% This class performs curve fitting for data with uncertainty in two
% directions....
%
% UNDER CONSTRUCTION


%
% See also MonteCarlo, Cloud
%

%
% created ???? by Daniel Dolan (Sandia National Laboratories)
%
classdef Fit2D
    %%
    properties (SetAccess=protected)
        Measurement = {} % Cell array of Density2D objects
        NumberMeasurements = 0 % Number of Cloud objects
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