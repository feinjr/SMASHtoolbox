% This class models joint probability density for two variables.  Variables
% are specified in a original coordinates (x,y), which are converted to
% scaled coordinates (u,v) using singular value decomposition.  Density
% information is internally stored in the scaled coordinate system, but
% queries can be made in either coordinate system. This class can be
% used for testing and exploration, but its true purpose is to support the
% CurveFit2D class.
%
% Creating a Density2D object defines several parameters used in density
% calculations.
%   object=Density2D(); % default settings
%   object=Density2D(name,value,...); % custom settings
% The density settings named below may be specified at object creation but
% cannot be changed in a existing object.
%    -GridPoints (1-2 integers)
%    -SmoothFactor (scalar value > 0)
%    -PadFactor (scalar value > 0)
%    -MinDensityFraction (scalar value > 0)
%    -ModeFraction (scalar value between 0 and 1)
%    -ContourFraction (array of values between 0 and 1)    
% 
% See also SMASH.MonteCarlo, CurveFit2D
%

%
% created March 3, 2016 by Daniel Dolan  (Sandia National Laboratories)
%
classdef Density2D
    %%
    properties
        GridPoints = [100 100] % Density estimation grid points
        SmoothFactor = 2 % Density smooth factor
        PadFactor = 5 % Density pad factor
        MinDensityFraction = 1e-9 % Minimum allowed density fraction
        ModeFraction = 0.90 % Density fraction for estimating mode location
        ContourFraction = 0.10:0.10:0.90 % Counter density fraction(s)  
    end
    properties (SetAccess=protected)
        Original % Original coordinate data
        Scaled % Scaled coordinate data
        Matrix % Tranformation matrix data
    end
    %%
    methods (Hidden=true)
        function object=Density2D(varargin)
            if (nargin==1) && ischar(varargin{1}) && strcmpi(varargin{1},'-empty')
                return % used by restore method
            end
            object=create(object,varargin{:});
        end
    end
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    %% setters
    methods
        function object=set.GridPoints(object,value)
            assert(isnumeric(value) && all(value==round(value)),...
                'ERROR: invalid grid points value');
            if isscalar(value)
                value=repmat(value,[1 2]);
            else
                assert(numel(value)==2,'ERROR: invalid grid points value');
                value=reshape(value,[1 2]);
            end
            object.GridPoints=value;
        end
        function object=set.SmoothFactor(object,value)
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid smooth factor value');
            object.SmoothFactor=value;
        end
        function object=set.PadFactor(object,value)
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid pad factor value');
            object.PadFactor=value;
        end
        function object=set.MinDensityFraction(object,value)
            assert(isnumeric(value) && isscalar(value) && ...
                (value>0) && (value<1),...
                'ERROR: invalid minimum density fraction value');
            object.MinDensityFraction=value;
        end
        function object=set.ContourFraction(object,value)
            assert(isnumeric(value) &&...
                all(value>0) && all(value<1),...
                'ERROR: invalid contour fraction value');
            object.ContourFraction=unique(value);
        end       
    end
end