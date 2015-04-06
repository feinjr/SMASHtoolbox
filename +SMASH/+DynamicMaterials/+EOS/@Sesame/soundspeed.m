% SOUNDSPEED  calculate the soundspeed a sesame table object
%
% This method returns the new soundspeed object for the input array
% of densities and temperatures
%
%    Usage:
%    >> new =soundspeed(object,density,temperature,rho0)
%
% rho0 is an optional parameter (defaults to stp) to convert to Lagrangian
% soundspeed. The Eulerian and Lagrangian soundspeeds are stored in Data{1}
% and Data{2}, respectively.
%
% See also Sesame, hugoniot, isobar, isochor, isotherm
%

% created April 2, 2015 by Justin Brown (Sandia National Laboratories)

function new=soundspeed(varargin)

% Error checking
if (nargin<3) 
    error('Invalid input. Require (obj,density,temperature)');
end

%Input initialization
object = varargin{1};
density = varargin{2};
temperature = varargin{3};


if ~isnumeric(density) || min(size(density)) > 1
    error('Invalid format for density. Must enter numeric row or column vector');
end

if size(temperature) ~= size(density)
    error('Density and temperature arrays must be the same size');
end


%Assume STP for rho0
rho0 = stp(object,density(1)); rho0 = rho0.Density;
if nargin > 3
    rho0 = varargin{4};
end   


%Calculate soundspeed
[e,dedr,dedt] = lookup(object,'Energy',density,temperature);
[p,dpdr,dpdt] = lookup(object,'Pressure',density,temperature);

if dpdr < 0
    temp = dpdr<0;
    warning('dP/dR reset to 0 as per Kerley EOS')
    dpdr(temp) = 0;
end

cb = sqrt(dpdr + (dpdt.*dpdt)./(density.*density)./dedt.*temperature);
cl = cb.*density./rho0;

% %Compute particle velocities
% up1=0;
% if length(density)==1
%     up = up1;
% else
%     up = up1 + cumtrapz(density,cl./density);
% end


pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature);

new = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);
new.Data{1}=cb;
new.Data{2}=cl;

%Set some properties
new.Name='SoundSpeed';
new.Source = 'Calculated';
new.SourceFormat='soundspeed';

end





