% ISOBAR Generate a curve of constant pressure from a sesame table object
%
% This method returns the new isobar sesame object for the input array
% of densities at the specified pressure
%
%   Usage:
%    >> new=isobar(object,density,pressure);
%
% A reverse lookup is performed for the density array at the given
% pressure.
%
% See also Sesame, hugoniot, isentrope, isochor, isotherm
%
% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new = isobar(object,density,pressure)

% Error checking
if (nargin<3) || isempty(density) || isempty(pressure)
    error('Invalid input. Require (obj,density,pressure);');
end

if ~isnumeric(density) || ~isnumeric(pressure) || min(size(density)) > 1
    error('Invalid format for x and y. Must enter numeric row or column vector for temperature and a numeric value for pressure');
end

pressure = repmat(pressure(1),size(density));
temperature = nan(size(density));

temperature = reverselookup(object,'Pressure',pressure,density);

% %Refine reverse lookup
% for i = 1:length(density)
%     temperature(i) = fzero(@(x) lookup(object,'Pressure',density(i),x)-pressure(i),temperature(i));
% end

energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature);
   
new = SMASH.EOS.Sesame(density,temperature,pressure,energy,entropy);

%Set some properties
new.Name= sprintf('%dGPa isobar',pressure(1));
new.Source = 'Calculated';
new.SourceFormat='isobar';
end



