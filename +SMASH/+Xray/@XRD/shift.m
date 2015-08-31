% SHIFT Shifts a XRD object by a scalar value
%
% Usage:
%   >> object=shift(object,coordinate,value)
% The "coordinate" input may be 'Grid1' or 'Grid2'.
%
% See also XRD, map, scale
%

% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)

function object=shift(object,varargin)

object.Measurement=shift(object.Measurement,varargin{:});

end