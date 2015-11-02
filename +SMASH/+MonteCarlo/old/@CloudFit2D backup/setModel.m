% setModel Define fit model
%
% This method defines the model associated with a 2D cloud fit.  Models are
% defined by a target function handle and a parameter array.
%     object=setModel(object,target,param);
%
% The target function must accept three inputs and return one output.
%     output=target(param,xbound,ybound);
%       param  : current parameter state (column vector)
%       xbound : characteristic bound of variable x ([xmin xmax])
%       ybound : characteristic bound of varaible y ([ymin ymax]);
%       output : two-column array of [x y] values
% Points in the output array will be connected in a piecewise linear
% fashtion with gaps wherever NaN values are found.
%
% The input "param" must be a column vector of parameter values understood
% by the target function.  Any valid parameter for the model can be
% used---the important thing is the number of parameters, which defines the
% degrees of freedom when the model is optimized with resepct to a dataset.
%  Usually, a set of plausible guess values are specified.
%
% See also CloudFit2D, setParameter
%

%
% created October 30, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=setModel(object,varargin)

object.Model=SMASH.MonteCarlo.Support.Model2D(varargin{:});

end