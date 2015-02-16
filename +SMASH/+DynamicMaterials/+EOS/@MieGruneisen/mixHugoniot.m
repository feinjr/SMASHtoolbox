% mixHugoniot applies Amagat mixture rule to two MieGruneisen objects to
% generate a new MieGruneisen object
%
%     >> object = evaluate(objectA,objectB,xA);
%
% where xA is the phase fraction of material A. 
%
% See also MieGruneisen, calibrate, calibrateUsup, evaluate,
% evaluateIsentrope, evaluateHugoniot, mixHugoniot

%
% created Februaruy, 3 2015 by Justin Brown (Sandia National Laboratories)
%
function object = mixHugoniot(objectA,objectB,xA)

%Error checking
assert(strcmpi(class(objectA),'SMASH.DynamicMaterials.EOS.MieGruneisen'),'ERROR: objectA is not a valid MieGruneisen object');
assert(strcmpi(class(objectB),'SMASH.DynamicMaterials.EOS.MieGruneisen'),'ERROR: objectB is not a valid MieGruneisen object');
assert(isscalar(xA) && isnumeric(xA),'xA must be a numeric scalar');

%Pick pressures between 0 - 9 MBar
P = linspace(0,900,100)';

%Find density according to Amagrat's rule
for i = 1:length(P)  
   rhoA(:,i) = fzero(@(x) evaluateHugoniot(objectA,x) - P(i),objectA.rho0);
   rhoB(:,i) = fzero(@(x) evaluateHugoniot(objectB,x) - P(i),objectB.rho0);
end
rho = 1./(xA./rhoA+(1-xA)./rhoB);

%Fit new object to pressure - density curve
object = SMASH.DynamicMaterials.EOS.MieGruneisen();
object.rho0 = rho(1);
object.c0 = objectA.c0*xA + objectB.c0*(1-xA);
object.s = objectA.s*xA + objectB.s*(1-xA);

object = calibrate(object,rho,P);

end