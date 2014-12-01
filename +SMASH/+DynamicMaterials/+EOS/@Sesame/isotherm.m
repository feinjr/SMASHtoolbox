% ISOTHERM Generate a curve of constant temperature from a sesame table object
%
% This method returns the isotherm sesame object for the input array
% of densities at the specified temperature
%
%   Usage:
%    >> new=isotherm(object,density,temperature);
%
% The pressure is interploated from the input density array and
% constant temperature.
%
% See also Sesame, hugoniot, isentrope, isobar, isochor
%
% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new=isotherm(object,density,temperature)

% Error checking
if (nargin<3) || isempty(density) || isempty(temperature)
    error('Invalid input. Require (object,density,temperature);');
end

if ~isnumeric(density) || ~isnumeric(temperature) || min(size(density)) > 1
    error('Invalid format for x and y. Must enter numeric row or column vector for density and a numeric value for temperature');
end

temperature = repmat(temperature(1),size(density));
pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature);

new = SMASH.EOS.Sesame(density,temperature,pressure,energy,entropy);

%Set some properties
new.Name= sprintf('%dK isotherm',temperature(1));
new.Source = 'Calculated';
new.SourceFormat='isotherm';
end