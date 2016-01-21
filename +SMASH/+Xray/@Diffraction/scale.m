% SCALE Multiply a Diffraction object by a scalar value
%
% Usage:
%   >> object=scal(object,coordinate,value)
% The "coordinate" input may be 'Grid1' or 'Grid2'.
%
% See also Xray, Diffraction, shift
%

%
% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)
% modified January 21, 2016 by Tommy Ao
%
function object=scale(object,varargin)

object.Measurement=scale(object.Measurement,varargin{:});

end