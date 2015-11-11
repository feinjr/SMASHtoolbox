% getPreference Get toolbox preferences
%
% This function gets preferences associated with the SMASH toolbox.
% Specific preferences are accessed by name.
%    value=getPreference(name);
% Omitting the name returns a structure containing all preferences
%    value=getPreference();
%
% Preference values are displayed in the command window if no output is
% specified.
%    getPreference(...);
%
%
% NOTE: preference settings are persistent within and between MATLAB
% sessions.
%
% See also System, setPreference
%

%
% created November 11, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=getPreference(name)

% manage input
if nargin==0
    value=getpref('SMASH');
else
    assert(isvarname(name) && ispref('SMASH',name),...
        'ERROR: invalid preference name');
    value=getpref('SMASH',name);   
end

% manage output
if nargout==0
    disp(value);
else
    varargout{1}=value;
end

end