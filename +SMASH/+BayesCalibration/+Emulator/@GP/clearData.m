% Clear variable data associated with the object
%
% This method clears the VariableData and ResponseData in a GP object:
%
%    >> object=clearData(object)
%
% This is useful for minimizing the GP size (after it is fit)
%
% See also GP, fit, evaluate
% 

%
% created June 20, 2016 by Justin Brown (Sandia National Laboratories)
%


function object=clearData(object)

object.VariableData = [];
object.ResponseData = [];

end