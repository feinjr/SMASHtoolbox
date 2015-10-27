% This class performs curve fitting for data with uncertainty in two
% directions....
%
% UNDER CONSTRUCTION

%Individual data points are represented by virtual cloud
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
classdef CloudFit2D
    %%
    properties (SetAccess=protected)
        CloudData = {} % Cell array of Cloud objects        
        NumberClouds = 0 % Number of Cloud objects
        ActiveClouds = [] % Active cloud indices        
        ActiveOptions = SMASH.Graphics.GraphicOptions % Active cloud graphic options        
        InactiveClouds = [] % Inactive cloud indices
        InactiveOptions = SMASH.Graphics.GraphicOptions % Inactive cloud graphic options
        CloudWeights % Array of cloud weights
    end
    properties
        %Model = SMASH.CurveFit.Model2D % 2D model object       
    end
    properties (SetAccess=protected) % eventally will be hidden
        
    end
    properties
        CloudSize = 100 % Maximum number of points per cloud
        %DrawSize = 1 % Cloud points drawn during each iteration
        %Iterations = 100 % Monte Carlo iterations
        XLabel = 'x' % Horizontal coordinate label
        YLabel = 'y' % Vertical coordinate label
    end
    %%
    methods (Hidden=true)
        function object=CloudFit2D(varargin)
            if nargin>0
                object=addCloud(object,varargin{:});
            end
           
        end
    end
    %% 
    %methods (Static=true, Hidden=true)
    %    function object=restore(data)
    %        error('ERROR: restore method is not ready yet!');
    %    end
    %end
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
        function object=set.XLabel(object,value)
            assert(ischar(value),'ERROR: invalid XLabel setting');
            object.XLabel=value;
        end
        function object=set.YLabel(object,value)
            assert(ischar(value),'ERROR: invalid YLabel setting');
            object.YLabel=value;
        end        
        %function object=set.WeightFunction(object,value)
        %    assert(ischar(value),'ERROR: invalid WeightFunction setting');
        %end
        %function object=set.Model(object,value)
        %    assert(isa(value,'SMASH.MonteCarlo.Model2D'),...
        %        'ERROR: invalid model object');
        %    object.Model=value;
        %end
    end
    
end