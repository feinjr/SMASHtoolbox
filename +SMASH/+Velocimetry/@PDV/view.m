% UNDER CONSTRUCTION
%
% show velocity with uncertainty
function varargout=view(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='velocity';
end
assert(ischar(mode),'ERROR: invalid mode');

%if isempty(object.Results)
%    error('ERROR: no Results available');
%end

switch lower(mode)
    case 'location'
        view(object.Results.Location,varargin{:});
    case 'velocity'
        view(object.Results.Velocity,varargin{:});
    otherwise
        error('ERROR: invalid view mode');
end

end