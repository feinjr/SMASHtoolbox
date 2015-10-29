% evaluate Evaluate model function
%
% This method evaluates the model function at a specified state.
% The state can be specified in terms of model parameters or the
% corresponding slack variables (default).
%     object=evaluate(object,slack); % evaluate slack state
%     object=evaluate(object,slack,'slack') % same as above
%     object=evaluate(object,param,'parameter',param); % evaluate parameter state
% The evaluated parameter state is returned as a second output in both
% modes.
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