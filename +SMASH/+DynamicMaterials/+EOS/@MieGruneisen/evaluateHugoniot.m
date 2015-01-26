% evaluate Evaluate Mie-Gruneisen model's principal Hugoniot at specified 
% density
%
%     >> [P, E, S] = evaluate(object,rho);
%
% using the MieGruneisen object. The pressure, free energy, and temperature
% are returned.
%
% See also MieGruneisen, calibrate, calibrateUsup, evaluate, evaluateIsentrope

%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function [P,E,T,S] = evaluateHugoniot(object,rho)

rho=rho(:);

%Avoid costly temperature and entropy calculations if not required
if nargout < 3
    [P,E] = calculateHugoniot(object,rho);
    T=0; E=0;
else
    [P,E,T,S] = calculateHugoniot(object,rho);

end