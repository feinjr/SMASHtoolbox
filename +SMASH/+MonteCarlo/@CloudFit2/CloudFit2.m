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
classdef CloudFit2
    %%
    properties (SetAccess=protected)
        CloudData = {} % Cell array of Cloud objects        
        NumberClouds = 0 % Number of Cloud objects
        ActiveClouds = [] % Indices of active Cloud objects
        ActiveOptions = SMASH.Graphics.GraphicOptions % Active cloud graphic options        
        InactiveClouds = [] % Indices of inactive Cloud objects
        InactiveOptions = SMASH.Graphics.GraphicOptions % Inactive cloud graphic options
        CloudWeights % Array of cloud weights
        ModelFunction % Function handle for model
        NumberParameters % Number of model parameters
        ModelParameters = struct % Structure array of parameter settings
        ModelCurve = SMASH.Graphics.LineSegments % Discrete representation of the model
        ModelCurveOptions=SMASH.Graphics.GraphicOptions; % Model curve graphic options
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
        function object=CloudFit2(varargin)
            if nargin>0
                object=setup(object,varargin{:});
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
        %function object=set.Iterations(object,value)
        %    assert(SMASH.General.testNumber(value,'integer'),...
        %        'ERROR: invalid Iterations setting');
        %    object.Iterations=value;
        %end
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
    end
    
end