% SHIFT Shifts a Diffration object by a scalar value
%
% Usage:
%   >> object=shift(object,coordinate,value)
% The "coordinate" input may be 'Grid1' or 'Grid2'.
%
% See also Xray, Diffraction, map, scale
%

% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)
% modified January 21, 2016 by Tommy Ao
%
function object=shift(object,varargin)

object.Measurement=shift(object.Measurement,varargin{:});

end