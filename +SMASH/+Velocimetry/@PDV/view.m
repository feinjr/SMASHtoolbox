% view View object graphically
%
% This method displays PDV objects as line plots.  The default view is the
% measured signal.
%     >> view(object);
%     >> view(object,'measurement'); % same as above
% Results can be viewed *after* the analysis method has been used.
%     >> view(object,'velocity');
%     >> view(object,'location');
%
% Specifying an output returns graphic handles for lines from this method.
%     >> h=view(...);
% 
% See also PDV
%

% 
% created March 2, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='velocity';
end
assert(ischar(mode),'ERROR: invalid mode');

switch lower(mode)
    case 'measurement'
        h=view(object.Measurement,varargin{:});
    case 'location'
        assert(~isempty(object.Results),'ERROR: no analysis results yet');
        h=view(object.Results.Location,varargin{:});
    case 'velocity'
        assert(~isempty(object.Results),'ERROR: no analysis results yet');
        h=view(object.Results.Velocity,varargin{:});
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout>0
    varargout{1}=h;
end

end