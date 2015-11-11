% setPreference Set toolbox preference(s)
%
% This function sets preferences used by the SMASH toolbox.  Preferences
% are defined by name/value pairs.
%    setPreference(name1,value1,...);
%
% NOTE: preference settings are persistent within and between MATLAB
% sessions.
% 
% See also System, getPreferences
%

%
% created November 11, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function setPreference(varargin)

% manage input
assert(rem(nargin,2)==0,'ERROR: unmatched name/value pair');

% store preferences in a group called SMASH
for n=1:2:nargin
    name=varargin{n};
    assert(isvarname(name),'ERROR: invalid preference name');
    value=varargin{n+1};
    setpref('SMASH',name,value);
end

end