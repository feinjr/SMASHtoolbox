% evaluate Evaluate model function
%
% This method evaluates the model function at a specified state. The state
% is specified by an array of slack/parameter values and limiting values of
% (x,y) for the evaluation.
%     object=evaluate(object,slack,xb,yb);
%     object=evaluate(object,slack,xb,yb,'slack') % same as above
%        slack : slack variable values
%        xb    : limiting values of x [xmin xmax]
%        yb    : limiting values of y [ymin ymax]
% To evaluate the model using a parameter values (instead of slack
% variables):
%     object=evaluate(object,param,xb,yb,parameter); 
%
% The evaluated parameter state is alwasy returned as a second output.
%     [object,param]=evaluate(...);
%
% The model evaluation is returned in the object's Curve property as a
% LineSegments2D object.
%
% See also Model2D, LineSegments2D

%
% created October 29, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function [object,param]=evaluate(object,param,xspan,yspan,mode)

% manage input
assert(nargin>=4,'ERROR: insufficient input');

if isempty(param)
    param=object.Parameters;   
    [object,param]=evaluate(object,param,xspan,yspan,'parameter');
    return
end

assert(numel(param)==object.NumberParameters,...
    'ERROR: invalid number of parameters');

if (nargin<5) || isempty(mode)
    mode='slack';
end
assert(ischar(mode),'ERROR: invalid evaluation mode');

% translate variables
if strcmp(mode,'slack')
    for n=1:object.NumberParameters
        param(n)=object.SlackFunction{n}(param(n));
    end
elseif strcmp(mode,'parameter')
    % do nothing
else
    error('ERROR: invalid evaluation mode');
end

% evaluate function
table=object.Function(param,xspan,yspan);
object.Curve=reset(object.Curve,table);