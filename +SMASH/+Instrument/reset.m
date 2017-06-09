% reset Clear instrument control objects
%
% This function clears instrument control objects from memory.  By default,
% all objects in the current session are cleared.
%    reset();
% Resetting can be restricted objects associated with a particular class.
% For example:
%    reset('Digitizer');
% clears only objects associated with the Digitizer class.
%
% See also Instrument
%

%
% created June 9, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function reset(target)

% manage input
if nargin < 1
    target='';
end
assert(ischar(target),'ERROR: invalid reset target');

switch lower(target)
    case ''
        delete(instrfindall());
    case 'digitizer'
        delete(instrfindall('Tag','Digitizer'));
    otherwise
        error('ERROR: invalid reset target');
end

end