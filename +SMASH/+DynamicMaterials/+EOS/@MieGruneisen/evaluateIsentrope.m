% evaluate Evaluate Mie-Gruneisen model isentrope for the specified
% density, beginning with the specified shock pressure, PH
%
%     >> [P, E, S] = evaluateIsentrope(object,rho,PH);
%
% using the model object. The pressure, Helmholtz free energy, and entropy
% are returned.
%
% See also MieGruneisen, calibrate, calibrateUsup, evaluateHugoniot,
% mixHugoniot

%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function [P,E,S] = evaluateIsentrope(object,rho,varargin)

rho=rho(:);

if nargin > 2
    assert(isscalar(varargin{1}),'PH must be scalar');
    PH = varargin{1};
else
    PH = 0;
end

%Solve for initial Hugoniot state
rho0 = object.rho0;
c0 = object.c0;
s = object.s;
g0 = object.gamma;

upH=c0/(2*s)*(sqrt(1+4*s/(rho0*c0^2).*PH)-1);
rhoH = rho0./(1-upH./(c0+s.*upH));
[PH,EH,TH,SH] = calculateHugoniot(object,rhoH);


%Calculate temperature along isentrope
gamma_v =@(v) g0.*rho0.*v;
integrand = @(v) gamma_v(v)./v;

for i=1:numel(rho)
    T(i) = TH.*exp(-integral(integrand,1./rhoH,1./rho(i)));
end

[P,E,S] = evaluate(object,rho,T);

end