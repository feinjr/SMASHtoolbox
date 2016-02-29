
% clouds2curve(x,y,'initialize');
% [distance,intersection]=clouds2curve(x,y,u,v)

% clouds array is [
function varargout=clouds2curve(clouds,varargin)

persistent AllowedAngles

% manage input
assert(nargin>=2,'ERROR: insufficient input');



if (nargin==2) && strcmpi(varargin{1},'initialize')
    AllowedAngles=initialize(clouds);
    return    
end

% manage output




end