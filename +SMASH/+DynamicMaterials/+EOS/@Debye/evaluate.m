% evaluate Evaluate Debye model at specified thermodynamic conditions
%
% This method evaluates a Debye object at specified density and temperature
%
%     >> [P, E, S] = evaluate(object,rho,T);
%
% using the model object. The pressure, internal energy, and entropy
% are returned.
%
% See also Debye, evaluateGamma, calibrateGamma

%
% created January 15, 2014 by Justin Brown (Sandia National Laboratories)
%
function [P,E,S] = evaluate(object,rho,T)

rho=rho(:);
T=T(:);

%Calculate specific gas constant
kb = 1.3806505e-23;     % Boltzmann (J/K)
m0 = 1.66053886e-27;    % Atomic mass constant (kg)
R = kb/object.A/m0*1e-6;


%Get Gruneisen and Debye temperature
[g,theta] = calculateDebyeTemp(object,rho);
tot = theta./T;

%Evaluate the third debye function
d3 = DebyeFunction(3,tot)

%Zero-point contributions
P0 = rho.*g.*9./8.*theta;
E0 = 9./8.*theta;
S0 = 0; 
%F0 = E0; 

%Thermal contributions
P = R.*(P0 + rho.*g.*3.*T.*d3); 
E = R.*(E0 + 3.*T.*d3); 
S = R.*(S0 + 4.*d3-3.*log(1-exp(-tot)));
%F = R.*(F0 + 3.*T.*log(1-exp(-tot)) - T.*d3);


end