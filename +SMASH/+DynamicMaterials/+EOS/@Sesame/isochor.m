% ISOCHOR Generate a curve of constant density from a sesame table object
%
% This method returns the isochor sesame object for the input array
% of temperatures at the specfied density
%
%   Usage:
%    >> new=isochor(object,temperature, density);
%
% The pressure is interploated from the input temperature array and
% constant density.
%
% See also Sesame, hugoniot, isentrope, isobar, isotherm
%

% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new =isochor(object,temperature,density)

% Error checking
if (nargin<3) || isempty(density) || isempty(temperature)
    error('Invalid input. Require (obj,density,temperature);');
end

if ~isnumeric(density) || ~isnumeric(temperature) || min(size(density)) > 1
    error('Invalid format for x and y. Must enter numeric row or column vector for density and a numeric value for temperature');
end

density = repmat(density(1),size(temperature));
pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature);

new = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);

%Set some properties
new.Name= sprintf('%dg/cc isochor',density(1));
new.Source = 'Calculated';
new.SourceFormat='isochor';

end



