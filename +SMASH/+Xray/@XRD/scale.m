% SCALE Multiply an XRD object by a scalar value
%
% Usage:
%   >> object=scal(object,coordinate,value)
% The "coordinate" input may be 'Grid1' or 'Grid2'.
%
% See also XRD, shift
%

%
% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)
%
function object=scale(object,varargin)

object.Measurement=scale(object.Measurement,varargin{:});

end