% This class manages models of two variables (x and y) with an arbitrary
% number of parameters.  Given a set of parameters, the model function
% generates a two-column table ([x y]).
%     table=model(param,xspan,yspan);
%        param : vector array of model parameters
%        xspan : characteristic span of variable x [min(x) max(x)]
%        yspan : characteristic span of variable y [min(y) max(y)]
% Each row of the output table is a point in the (x,y) plane.  Adjacent
% table points are connected in a piece-wise linear fashion.
% Discontinuities between points are specified by rows containing a NaN
% value.
%
% Models are constructed with a function handle and an array of parameter
% values.
%     object=Model2D(target,param);
% The target function must accept three inputs as described above.  The
% second input specifies an initial parameter state, which is usually a
% param for the optimal values (with respect to some dataset).  The param
% input must be a numeric array (arbitrary size/shape) understood by the
% target function.
%

%
% created October 29, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef Model2D
    %%
    properties (SetAccess=protected)
        Function % Model function (function handle)
        Parameters % Model parameters (column vector)
        Bounds % Parameter bounds (1x2 array)
        SlackVariables % Slack variables (column vector)
    end
    properties
        Curve=SMASH.MonteCarlo.Support.LineSegments2D() % LineSegments2D object
        OptimizationSettings=optimset(); % Optimization settings (optimset structure)
    end
    %%
    properties (SetAccess=protected)
        NumberParameters % Number of model parameter
        SlackFunction % Slack variable conversions (cell array of function handles)
    end
    %%
    methods (Hidden=true)
        function object=Model2D(target,param)
            % manage input
            assert(nargin>=2,'ERROR: invalid number of inputs');
            assert(isa(target,'function_handle'),...
                'ERROR: invalid function handle');
            assert(isnumeric(param),'ERROR: invalid parameter array');
            
            % assign settings
            object.Function=target;
            object.Parameters=param(:);
            object.NumberParameters=numel(param);
            
            object.Bounds=repmat([-inf +inf],[object.NumberParameters 1]);
            object.SlackVariables=zeros([object.NumberParameters 1]);
            
            object.SlackFunction=cell([object.NumberParameters 1]);
            for n=1:object.NumberParameters
                object.SlackFunction{n}=@(q) param(n)+q;
            end
            
        end
    end
    %% restore method allows objects to be restored from SDA files
    methods (Static=true, Hidden=true)
        function object=restore(data)
            object=SMASH.MonteCarlo.Support.Model2D(...
                data.Function,data.Parameters);
            data=rmfield(data,{'Function','Parameters'});
            name=fieldnames(data);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=data.(name{n});
                end
            end
        end
    end
    %% setters
    methods
        function object=set.Curve(object,value)
            assert(isa(value,'SMASH.MonteCarlo.Support.LineSegments2D'),...
                'ERROR: invalid Curve setting');
            object.Curve=value;
        end
        function object=set.OptimizationSettings(object,value)
            try
                value=optimset(value);
            catch
                error('ERROR: invalid optimization settings');
            end
            object.OptimizationSettings=value;
        end
    end
end