% STP generates the point of standard temperature and pressure for the
% object
%
% This method returns STP conditions for the object. In this case STP is
% defined using the ambient convention: T= 298.15 K, P = 1 bar.
%
%   Usage:
%    >> new=stp(object);
%    >> new=stp(object, rho guess);
%
% See also Sesame, hugoniot, isentrope, isobar, isochor
%

% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new=stp(varargin)

p0 = 100e-6;
t0 = 298.15;

%Input initialization
object = varargin{1};

%Initial guess for density
dguess = mean(object.Density);

if nargin > 1
    dguess = varargin{2};
end
if nargin > 2
    t0 = varargin{3};
end

conv_check = 0;
while ~conv_check
    [density,~,conv_check] = fzero(@(x) lookup(object,'Pressure',x,t0)-p0,dguess);
    dguess = dguess*1.5;
end

temperature = t0;

pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature);

new = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);

%Set some properties
new.Name= sprintf('STP');
new.Source = 'Calculated';
new.SourceFormat='STP point';
end