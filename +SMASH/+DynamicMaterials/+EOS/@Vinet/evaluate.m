% evaluate Evaluate Vinet model at specified thermodynamic conditions
%
% This method evaluates a Vinet object at specified density and temperature
%
%     >> [P,S,G] = evaluate(object,rho,T);
%
% using the model object. The pressure, entropy, and Gibb's free energies
% are returned.
%
% See also Vinet, calibrate

%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function [P,S,G] = evaluate(object,rho,T)

rho=rho(:);
T=T(:);

[P,S,G] = calculateVinet(object,rho,T);

end