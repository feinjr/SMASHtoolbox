% SMOOTH Smooth the XRD Data over a local neighborhood
%
% Usage:
%   >> object=smooth(object,choice,value);
% "choice" can be 'mean', 'median', or 'kernel' (advanced users only)
% "value" is the smoothing neighborhood (e.g., [3 3]) or kernel weights
%
% See also XRD

% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)
%
function object=smooth(object,varargin)

object.Measurement=smooth(object.Measurement,varargin{:});

end