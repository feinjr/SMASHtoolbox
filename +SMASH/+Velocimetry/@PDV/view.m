% UNDER CONSTRUCTION
%
% show velocity with uncertainty
function varargout=view(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='velocity';
end
assert(ischar(mode),'ERROR: invalid mode');

if isempty(object.Results)
    error('ERROR: no analysis results yet');
end

switch lower(mode)
    case 'location'
        h=view(object.Results.Location,varargin{:});
    case 'velocity'
        h=view(object.Results.Velocity,varargin{:});
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout>0
    varargout{1}=h;
end

end