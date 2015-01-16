% evaluate Evaluate Debye model gamma
%
% This method evaluates a Debye object at a specified density
%
%     >> g = evaluate(object,rho);
%
% using the model object. The Gruneisen coefficient is returned.
%
% See also Debye, evaluate, calibrateGamma

%
% created January 15, 2014 by Justin Brown (Sandia National Laboratories)
%
function g = evaluateGamma(object,rho)

rho=rho(:);

%Get Gruneisen and Debye temperature
[g,theta] = calculateDebyeTemp(object,rho);

end