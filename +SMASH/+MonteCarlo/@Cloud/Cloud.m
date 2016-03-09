% This class creates represents statistical variations in a set of
% variables as a data cloud.  Each dimension of the data cloud represents a
% single variable.  Variables can be assigned distinct statistical
% moments: means and variances are required, skewness and excess
% kurtosis are optional.  Correlations between variables can also be
% specified.
%
% Data clouds represent continuous variable relationships with a finite set
% of points.  These points are stored as a table in the Data property of
% Cloud objects.  Each column of the table corresponds to a specific
% variable.  The data table is usually generated from specified moments and
% correlations.
%     object=Cloud(moments); % uncorrelated variables
%     object=Cloud(moments,correlations); % specified correlations
%     object=Cloud(moments,correlations,Npoints); % overide 1000 point default
% where the moments array has 2-4 columns [mean variance skewness
% kurtosis].  Each row of the moments array defines a cloud variable, so
% the number of rows M defines the dimensionality.  Variable correlations
% can be specified by a symmetric MxM matrix of values from -1 to +1.
%
% NOTE: the actual statistics of a data cloud may differ from the specified
% moments and correlations.  This difference arises from finite cloud size.
% Increasing the number of cloud points reduces, but does not eliminate,
% such differences.
%
% Cloud objects can also be created from an existing data table.
%    >> object=Cloud(table,'table');
% Statistical moments and correlations are derived from the specified
% table.  Depending on the underlying distributions, clouds generated from
% these moments/correlations may differ from the source data.
%
% See also SMASH.MonteCarlo
%

%
% created April 29, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised August 5, 2014 by Daniel Dolan
%    -modifed input handling
%    -simplified execution, eliminating all obsolete DataCloud references
%    -enabled manual object creation with a data table
% revised July 4, 2015 by Daniel Dolan
%    -massive cleanup in progress
% revised November 18, 2015 by Daniel Dolan
%    -removed ellipse, converted 2D density to contours
classdef Cloud %< SMASH.General.DataClass
    %%
    properties (SetAccess=protected)
        NumberVariables % Number of variables (cloud dimensions)
        VariableName % Variable names (cell array of text strings)     
        Moments % Statistical moments array [mean variance skew kurtosis] (2-4 columns)
        Correlations % Correlation matrix (symmetric)
        NumberPoints = 1000 % Number of cloud points
        Data % Cloud data table (columns represent variables)
        Source % Data soure: 'moments', 'table', 'transform', or 'bootstrap'
        Seed = [] % Random number generator seed (uint32 value or text string)                         
        DensitySettings % Density estimation options
    end
    %% constructor
    methods (Hidden=true)
        function object=Cloud(varargin)
            if (nargin==1) && strcmp(varargin{1},'-empty')
                return
            end
            object=create(object,varargin{:});
        end
        varargout=ellipse(varargin);
    end
    %%
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
    end
    %%
    methods (Static=true,Hidden=true)
        varargout=restore(varargin);
    end    
end