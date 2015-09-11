%% LOOKUP Look up XRD data values at specific grid locations
%
% This method returns interpolated data values for specified grid
% locations.
%    >> z=lookup(object,x,y);
% See also XRD
%

%
% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)
%
function z=lookup(object,varargin)

z=lookup(object.Measurement,varargin{:});

end