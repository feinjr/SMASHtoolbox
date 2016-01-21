% FLIP Flip Diffraction object Data along a specified coordinate
%
% Usage:
% >> object=flip(object,coordinate);
% The "coordinate" may be 'Grid1' or 'Grid2'.
%
% See also Xray, Diffraction
%

%
% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)
% modified January 21, 2016 by Tommy Ao
%
function object=flip(object,varargin)

object.Measurement=flip(object.Measurement,varargin{:});

end