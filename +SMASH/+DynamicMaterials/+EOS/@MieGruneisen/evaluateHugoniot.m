% evaluate Evaluate Mie-Gruneisen model's Hugoniot at specified density
%
%     >> [P, E, S] = evaluate(object,rho,T);
%
% using the model object. The pressure, free energy, and temperature are
% returned.
%
% See also Model
%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function [P,E,T,S] = evaluateHugoniot(object,rho)

rho=rho(:);

[P,E,T,S] = calculateHugoniot(object,rho);

end