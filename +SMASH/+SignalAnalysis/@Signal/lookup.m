% LOOKUP Look up data values at specific grid locations
%
% This method returns interpolated data values for specified grid
% locations.
%    >> y=lookup(object,x);
%
% See also Signal, regrid
% 

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function y=lookup(object,x)

% handle input
if (nargin<2) || isempty(x)
    error('ERROR: no grid location(s) specified');
end

y=interp1(object.Grid,object.Data,x,'linear');

end