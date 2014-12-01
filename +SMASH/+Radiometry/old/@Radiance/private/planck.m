% A black body radiator is an idealized physical body that absorbs all 
% incident electromagnetic radiation, regardless of frequency or angle of 
% incidence.  Blackbody radiation has a characteristic, continuous 
% spectrum that depends only on the body's temperature defined by
% Planck's law.
%
% A black body in thermal equilibrium has an emissivity of 1.0. A source 
% with lower emissivity (0<emissivity<1.0) is referred to as a gray body.
%
% created March 26, 2014 by Tommy Ao (Sandia National Laboratories)
%
function radiance=planck(wavelength,temperature,emissivity)

% handle input
wavelength=wavelength/1e3; % convert nm to um

if (nargin<2) || isempty(temperature)
    error('ERROR: No temperature input');
end

if (nargin<3) || isempty(emissivity)
    emissivity=ones(size(wavelength));
end

% physical constants
c1=1.1911e8; % W*um^4/m^2/sr
c2=1.4388e4; % um*K
radiance=c1./wavelength.^5./(exp(c2./(wavelength*temperature))-1);
radiance=radiance.*emissivity;

end