% SMOOTH Smooth the Diffraction Data over a local neighborhood
%
% Usage:
%   >> object=smooth(object,choice,value);
% "choice" can be 'mean', 'median', or 'kernel' (advanced users only)
% "value" is the smoothing neighborhood (e.g., [3 3]) or kernel weights
%
% See also Xray, Diffraction
%

% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)
% modified January 21, 2016 by Tommy Ao
%
function object=smooth(object,varargin)

object.Measurement=smooth(object.Measurement,varargin{:});

end