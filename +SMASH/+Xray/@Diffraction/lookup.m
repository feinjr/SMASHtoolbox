% LOOKUP Look up Diffraction data values at specific grid locations
%
% This method returns interpolated data values for specified grid
% locations.
%    >> z=lookup(object,x,y);
%
% See also Xray, Diffraction
%

%
% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)
% modified January 21, 2016 by Tommy Ao
%
function z=lookup(object,varargin)

z=lookup(object.Measurement,varargin{:});

end