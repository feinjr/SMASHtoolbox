% This class creates objects for Monte Carlo analysis, representing
% statistical variation as a cloud of points.  Each dimension of the cloud
% represents a variable with its own statistical properties; variable
% correlations can also be specified.  Cloud points are stored as a table,
% each column representing a particular variable, in the object's 'Data'
% property.
%
% To create a Cloud object, type:
%    >> object=Cloud(moments,[correlations],[points]);
% The statistical moments of the cloud are specified by a table with
% 2-4 columns.  Each row of the table defines the properties of a
% single variable.  The first two columns define the mean and variance
% of each variable, respectively.  Optional third and fourth columns
% define the skewness and (excess) kurtosis; these parameters default
% to zero, resulting in normal distribution(s). The remaining inputs are
% optional.
%    - A correlations matrix can be specified to link variations between
%     variables.  This input must be square, symmetric, and contain values
%     between -1 and +1 (inclusive) with +1 along the diagonal.  The
%     default value is the identity matrix.
%    - The number of cloud points can be any integer greater than 0.  The
%    default value is 1000.
% Cloud properties can be modified object creation.  For example:
%    >> object=Cloud([0 1; 1 1; 2 1]); % 1000 point centered at (0,1), variance=1
%    >> object.Points=25;
%    >> object.Moments=[0 2; 2 2; 3 2];
%    >> object.Correlations=[1 +0.5 0; +0.5 1 0; 0 0 1];
%    >> object=regenerate(object);
% changes a 1000-point cloud centered at (0,1,2) with a common variance of 1
% to a 25-point cloud centered at (0,2,3) with a common variance of 2.  Note
% that the object's data table is not updated until the regenerate method
% is called.
%
% Cloud objects can also be created by manually passing a data table.
%    >> object=Cloud(table,'table');
% Each column of the table represents one cloud dimension.
%
% See also MonteCarlo
%

% created April 29, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised August 5, 2014 by Daniel Dolan
%    -modifed input handling
%    -simplified execution, eliminating all obsolete DataCloud references
%    -enabled manual object creation with a data table
classdef Cloud %< SMASH.General.DataClass
    %%
    properties
        Seed = []; % Random number generator seed
        NumberPoints = 1000 % Number of cloud points
        Moments % Statistical moments
        Correlations % Correlation matrix
        VariableName % cell array of text labels
        Width % widths used in histograms and kernel density estimates
    end
    properties (SetAccess=protected)
        Data % Random data table (columns = variables)
        NumberVariables % Cloud dimensions
        Source % moments, table, apply, or bootstrap
    end
    %% constructor
    methods (Hidden=true)
        function object=Cloud(varargin)
            object=create(object,varargin{:});        
        end
    end
    %% 
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);
        varargout=histogram(varargin);
        varargout=density(varargin);
        varargout=ellipse(varargin);
    end
    %% utility methods
    %methods (Access=protected,Hidden=true)
    %    varargout=selectVariables(varargin)
    %end
    %% property setters
    methods
        function object=set.Moments(object,moments)
            [M,N]=size(moments);
            assert((N>=2) && (N<=4),'ERROR: invalid moments table');
            object.Moments=zeros(M,4);
            object.Moments(:,1:N)=moments;
        end
        function object=set.Correlations(object,correlations)
            [M,N]=size(correlations);
            assert(M==N,'ERROR: invalid correlation matrix');
            assert(M==object.NumberVariables,...
                'ERROR: correlation matrix not compatible with moments table'); %#ok<MCSUP>
            valid=(correlations>=-1) & (correlations<=+1);
            assert(all(valid(:)),...
                'ERROR: correlations below -1 and/or above +1 detected');
            object.Correlations=correlations;
        end        
        function object=set.NumberPoints(object,points)
            assert(...
                SMASH.General.testNumber(points,'positive','integer') & ...
                points>10,'ERROR: invalid number of points');
            object.NumberPoints=points;
        end
        function object=set.Seed(object,seed)
            if isempty(seed) || ischar(seed)
                % do nothing
            elseif isnumeric(seed) && isscalar(seed)
                % do nothing
            else
                error('ERROR: invalid seed value');
            end
            object.Seed=seed;
        end
        function object=set.Width(object,width)
            assert(isnumeric(width),'ERROR: invalid bin width(s) setting');
            if isempty(object.Width)
                object.Width=width;
            elseif isempty(width)
                width=nan(size(object.Width));
            end
            if numel(width)==1
                width=repmat(width,size(object.Width));
            end
            assert(numel(width)==numel(object.Width),...
                'ERROR: invalid number of bin widths');
            object.Width=width;
        end
    end
end