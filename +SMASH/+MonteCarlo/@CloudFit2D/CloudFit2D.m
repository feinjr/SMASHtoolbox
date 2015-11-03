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
    properties
        CloudData = {} % Cell array of Cloud objects
    end
    properties (SetAccess=protected)
        NumberClouds = 0 % Number of Cloud objects
        ActiveClouds = [] % Active cloud indices
        CloudWeights % Cloud weights (column vector)
        InverseElements % Inverse covariance matrix elements ([a bc d] columns)
    end
    properties
        ViewOptions = processViewOptions() % Display options (structure)
        NumberDraws = 1 % Points drawn from each cloud for model optimization
        Recenter = false % Recenter point(s) drawn from cloud
        DrawMode = 'standard' % Draw mode ('standard' or 'economy'?)
    end
    properties (SetAccess=protected)
        Model  = struct('Function',[],'Parameters',[],'Bounds',[],...
            'Slack',[],'SlackReference',[],'Curve',[]) %      
    end  
    properties
        OptimizationSettings=optimset();
    end
    %%
    methods (Hidden=true)
        function object=CloudFit2D(varargin)
            if nargin>0
                object=addCloud(object,varargin{:});
            end
        end
        %varargout=calculateWeights(varargin);
    end
    %%
    methods (Static=true, Hidden=true)
        function object=restore(data)
            object=SMASH.MonteCarlo.CloudFit2D();            
            name=fieldnames(data);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=data.(name{n});
                end
            end
        end
    end
    %% property setters
    methods
        function object=set.CloudData(object,value)
            assert(iscell(value),'ERROR: invalid cloud data');
            for n=1:numel(value)
                assert(isa(value{n},'SMASH.MonteCarlo.Cloud'),...
                    'ERROR: invalid cloud data');
            end
            object.CloudData=value;
        end
        function object=set.ViewOptions(object,value)
            object.ViewOptions=processViewOptions(value);
        end       
        function object=set.NumberDraws(object,value)
            assert(...
                SMASH.General.testNumber(value,'integer','positive','notzero'),...
                'ERROR: invalid number of draws');
            object.NumberDraws=value;
        end
        function object=set.Recenter(object,value)
            assert(islogical(value),'ERROR: invalid recenter value');
            object.Recenter=value;
        end
        function object=set.DrawMode(object,value)
            assert(ischar(value),'ERROR: invalid draw mode');
            value=lower(value);
            switch value
                case 'standard'
                    object.DrawMode=value;
                case 'economy'
                    error('ERROR: economy mode not supported yet');
                otherwise
                    error('ERROR: invalid draw mode');
            end
        end
        function object=set.OptimizationSettings(object,value)
            try
                value=optimset(value);
            catch
                error('ERROR: invalid optmization settings');                
            end
            object.OptimizationSettings=value;
        end
    end
    
end