% object2structure Convert object to structure
%
% UNDER CONSTRUCTION
%
% See also General
%

%
%
%
function data=object2structure(object)

warning off MATLAB:structOnObject
data=struct(object);
warning on MATLAB:structOnObject

end