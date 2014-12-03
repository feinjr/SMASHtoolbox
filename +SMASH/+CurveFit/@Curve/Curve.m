% This class describes the relationships between independent variable x and
% dependent variable y as a summation of basis functions f(p,x).
%     y(x) = B1*f1(p1,x) + B2*f2(p2,x) + ...
% Each basis function has a set of internal parameters (p1, p2, etc.) and
% an external scaling factor (B1, B2, etc.).  Given a (x,y) data set, the
% internal parameters are determined via iterative optimization.  External
% parameters are determined with non-iterative, linear least=squares method
% or left fixed.
% 
% Curve objects are created with no input arguments.
%     >> object=Curve;
% Basis functions in the object are controlled with the add, edit, and
% remove methods.  The summarize and evaluate methods describe the current
% object state.  Parameter optimization is provided with the fit method.
% 
% See also CurveFit, makeBackground, makePeak, makeStep
%

%
% created November 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef Curve
    %% properties
    properties (SetAccess=protected)
        Basis = {} % Basis function handles
        Parameter = {} % Basis function variables
        Bound = {} % Variable bounds (lower/upper)
        Scale = {} % Basis scaling factors
        FixScale = {} % Fixed scaling factor settings
    end
    %% methods
    methods (Hidden=true)
        function object=Curve(varargin)
        end
    end
end