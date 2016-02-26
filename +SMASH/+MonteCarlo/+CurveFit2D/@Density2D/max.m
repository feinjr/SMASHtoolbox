
function [value,location]=max(object,mode,segment)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(isa(segment,'SMASH.MonteCarlo.primitive.LineSegments2D'),...
    'ERROR: invalid line segment(s) input');
% more to do here...

if (nargin<3) || isempty(mode)
    mode='normal';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case {'normal' 'general'}
        % valid mode
    otherwise
        error('ERROR: invalid mode');
end

% process line segments

end