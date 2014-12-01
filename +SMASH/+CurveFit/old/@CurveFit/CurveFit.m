classdef CurveFit
    properties (SetAccess=protected)
        Data % (x,y) data table
        BasisFunction = {} % Basis function
        Scalable  % 
        Guess % Parameter guess
        LowerBound % Lower bound
        UpperBound % Upper bound
        Result % parameters, scale factors, and fit
    end
    properties (Access=protected)
        BasisIndex % Basis index array
    end
    %%
    methods (Hidden=true)
        function object=CurveFit(varargin)
            object=define(object,varargin{:});
        end
    end
    
    
end