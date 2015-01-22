% This method evaluates the Mie-Gruneisen object at the specified density
% and temperature
%
%     >> [P, E, S] = calculateMG(object,rho,T);
%
% The pressure, Helmholtz free energy, and entropy are returned.
%
% If a parameter set p is given, the object's Hugoniot parameters are
% overwritten
%
%    >> [P, E, S] = calculateMG(object,rho,T,[c0,s]);
%
% See also MieGruneisen, evaluate, calibrate
%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function [P,E,S] =calculateMG(object,rho,T,varargin)

rho=rho(:);
T=T(:);
    

rho0=object.rho0;
g0=object.gamma;
cv0=object.cv;
T0 = object.T0;

if nargin > 3
    p = varargin{1};
    c0 = p(1);
    s = p(2);
end

%% Reference states
E0 = cv0.*T0;
P0 = g0.*rho0.*E0;
%Calculate reference entropy - might be better to use Debye here?
integrand = @(T) cv0./T;
S0 = integral(integrand,0,T0);


% calculate Hugoniot
[PH,EH,TH,SH]=calculateHugoniot(object,rho);

% off Hugoniot
E = E0 + EH + cv0.*(T-TH);
P = PH + g0.*rho0.*cv0.*(T-TH);
xi = @(v) exp(g0*rho0*(1/rho0-v));
S = S0 + cv0.*log(T./(T0.*xi(1./rho)));


% generalized gamma
%gamma_v = @(v) rho.*g0.*v;
%E = EH + cv0.*(T-TH);
%P = PH + gamma_v(1./rho).*rho.*(E-EH);

    

end