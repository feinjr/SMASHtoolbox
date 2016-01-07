% setDefaultFontSize Set default font size
%
% This function sets the default font sizes used in MATLAB figures.  
%    setDefaultFontSize(value); % font size in points
% Axes text and uicontrols created *after* this function call will be rendered
% at the specified font size unless otherwise instructed.  Font sizes must
% be a positive number.  Extremely small (<5) or large (>50) values are
% accepted but will generate a warning.
%
% See also System
%

%
% created January 7, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function setDefaultFontSize(value)

% manage input
assert(isnumeric(value) && isscalar(value) && (value>0),...
    'ERROR: invalid font size');
if (value<5) || (value>50)
    warning('SMASH:FontSize','Requested size is suspicously small or large');
end

% apply request
set(0,'DefaultAxesFontUnits','points',...
    'DefaultAxesFontSize',value);
set(0,'DefaultUIControlFontUnits','points',...
    'DefaultUIControlFontSize',value);


end