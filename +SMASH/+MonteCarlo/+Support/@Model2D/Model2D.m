% This class manages two-dimensional models using an arbitrary number of
% parameters.  Given a set of parameters, the model function generates a
% two-column ([x y]) table.
%     table=model(param);
% The parameter array controls the model's underlying behavior, and in
% principle these parameters could be optimized to match a set of (x,y)
% measurements.
%
% Models are defined by a function handle and an array of parameter
% guesses.
%     object=Model2D(target,guess);
% The model function "target" must accept a parameter array as the first
% argument.  Additional input arguments for
% the model function can be managed through an intermediate function
% handle.
%     target=@(p) model(p,arg1,arg2,...);
%
% By default, model parameters are unconstrained.  One-side and two-sided
% constraints may be applied to each parameter using the bound method.
%
%

%
% created October 27, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef Model2D
    %%
    properties (SetAccess=protected)
        Function % Model function handle
        Parameters % Array of model parameters
        Bounds % Array of parameter bounds [lower upper]
        SlackVariables % Array of slack variables
        Curve=SMASH.MonteCarlo.Support.LineSegments() % LineSegments object
    end
    properties
        Options=optimset;
    end
    %%
    properties (SetAccess=protected)
        NumberParameters
        SlackFunction        
    end
    %%
    methods (Hidden=true)
        function object=Model2D(target,guess)
            % manage input
            assert(nargin==2,'ERROR: invalid number of inputs');
            assert(isa(target,'function_handle'),...
                'ERROR: invalid function handle');
            assert(isnumeric(guess),'ERROR: invalid parameter array');
            
            % assign settings
            object.Function=target;
            object.Parameters=guess(:);
            object.NumberParameters=numel(guess);
            
            object.Bounds=repmat([-inf +inf],[object.NumberParameters 1]);
            object.SlackVariables=zeros([object.NumberParameters 1]);
            
            object.SlackFunction=cell([object.NumberParameters 1]);
            for n=1:object.NumberParameters
                object.SlackFunction{n}=@(q) guess(n)+q;
            end
            
        end
    end
end