% ROTATE Rotate XRD object Data along a specified angle
%
% Usage:
% >> object=rotate(object,angle);
% The "angle" may be scalar angle (in degrees) or an orientation such as 
% "left", "right", "clockwise", or "counter-clockwise".
%
% See also XRD, rotate
%

%
% created November 17, 2015 by Tommy Ao (Sandia National Laboratories)

function object=rotate(object,varargin)

object.Measurement=rotate(object.Measurement,varargin{:});

end