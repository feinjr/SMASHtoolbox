% This class approximates probability density for a two-dimensional data
% point with uncertainty in both directions.  This approximation uses a set
% of cloud points to represent uncertainty about that actual data point.
% The measurement can be defined directly by a Cloud object or as a table
% of statistical properties (means, variances, etc.).
%    object=Density2D(source); % source cloud
%    object=Density2D(table,numpoints); % statistical table (see createCloud2D function)
% Additional inputs may be passed to customize density estimation; see the
% estimate method for more details.
%
% Data passed to this class uses original coordinates (x,y).  Internally,
% these values are transformed to final coordinates (u,v) by singular value
% decomposition.  Normally distributed (x,y) data becomes normally
% distributed (u,v) data with equal variance and no linear correlation.
% Forward (original to final) and reverse (final to original)
% matrices handle transformations between coordinate systems.
%
% See also CurveFit2D, createCloud2D
%
%

%
% created February 26, 2016 by Daniel Dolan (Sandia National Laboratories)
%
classdef Density2D
    %%
    properties
        AssumeNormal = false % Assume normal distributions (true/false)
    end
    properties (SetAccess=protected)
        Original % Density information in the original coordinates
        Final % Density information in the final (principle) coordinates
        Matrix % Coordinate transformation matrices
        Setting % Density calculation settings (read only)
    end
    %%
    methods (Hidden=true)
        function object=Density2D(varargin)
            assert(nargin>0,'ERROR: insufficient input');
            if (nargin==1) && strcmpi(varargin{1},'-empty')
                return
            end
            object=estimate(object,varargin{:});
        end
    end
    %%
    methods (Static=true,Hidden=true)
        varargout=restore(varargin);
    end
    %%
    methods
        function object=set.AssumeNormal(object,value)
            assert(islogical(value),'ERROR: invalid AssumeNormal value');
            object.AssumeNormal=value;
        end
    end
end