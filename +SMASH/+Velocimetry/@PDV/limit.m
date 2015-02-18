% limit Limit object to a region of interest
%
% This method defines a region of interest in a PDV object, limiting the
% time range used in calculations and visualization.
%     >> object=limit(object,[tmin tmax]); % specify limited region
%     >> object=limit(object,'all'); % use all times
%
% See also PDV
%

%
% created February 18, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=limit(object,varargin)

object.Measurement=limit(object.Measurement,varargin{:});

end