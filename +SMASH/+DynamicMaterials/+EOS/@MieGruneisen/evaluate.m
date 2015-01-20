% evaluate Evaluate Mie-Gruneisen model at specified thermodynamic conditions
%
% This method evaluates a MieGruneisen object at specified density and temperature
%
%     >> [P, E, S] = evaluate(object,rho,T);
%
% using the model object. The pressure, Helmholtz free energy, and entropy
% are returned.
%
% See also MieGruneisen, calibrate, calibrateUsup, evaluateHugoniot

%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function [P,E,S] = evaluate(object,rho,T)

rho=rho(:);
T=T(:);

[P,E,S] = calculateMG(object,rho,T);

end