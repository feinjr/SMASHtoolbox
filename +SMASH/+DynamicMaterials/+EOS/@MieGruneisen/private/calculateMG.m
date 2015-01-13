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

if nargin > 3
    p = varargin{1};
    c0 = p(1);
    s = p(2);
end

% calculate Hugoniot
[P0,E0,T0,S0]=calculateHugoniot(object,object.rho0);
[PH,EH,TH,SH]=calculateHugoniot(object,rho);

% off Hugoniot
E = EH + cv0.*(T-TH);
P = PH + g0.*rho0.*(E-EH);

% generalized gamma
%gamma_v = @(v) rho.*g0.*v;
%E = EH + cv0.*(T-TH);
%P = PH + gamma_v(1./rho).*rho.*(E-EH);

%Calculate S with numerical derivatives
S=zeros(size(E));
for i = 1:length(E)
    dv=1./rho(i)+1e-8;
    [PHi,EHi,THi,SHi]=calculateHugoniot(object,rho(i));
    de = E(i)+EHi+cv0.*(T-THi);
    ds = (de+P(i).*dv)./T;
    S(i)=ds;
end
    

end