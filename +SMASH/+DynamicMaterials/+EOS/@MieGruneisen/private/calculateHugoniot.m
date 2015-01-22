% This method evaluates the MieGruneisen object's Hugoniot at the specified
% density
%
%     >> [PH,EH,TH] = calculateHugoniot(object,rho);
%
% The pressure and internal energy are returned.
%
% If a parameter set p is given, the object's Hugoniot parameters are
% overwritten
%
%    >> [PH,EH,TH,SH] = calculateHugoniot(object,rho,T,[c0,s]);
%
% See also MieGruneisen, evaluate, calibrate
%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function [PH,EH,TH,SH] =calculateHugoniot(object,rho,varargin)

rho=rho(:);

rho0=object.rho0;
c0 = object.c0;
s = object.s;
g0=object.gamma;
T0 = object.T0;
cv0=object.cv;

if nargin > 2
    p = varargin{1};
    c0 = p(1);
    s = p(2);
end



%% Hugoniot states
v = 1./rho; v0 = 1./rho0;
eta = 1.0-rho0./rho;
%EH = 0.5.*(c0.*(v0-v)).^2./(v0-s.*(v0-v)).^2;
PH = rho0.*c0.^2.*eta./((1-s.*eta).^2);
EH = PH.*eta./(2.*rho0);
%dPHdeta = rho0.*c0.^2.*(1+s.*eta)./((1-s.*eta).^3);
%dPHdV = -dPHdeta.*rho0


TH = repmat(0,size(v));
SH = repmat(0,size(v));


%% Temperature and entropy are expensive - only calculate if requested
if nargout > 2
% Davison, Fundamentals of Shock Propogation in Solids, p. 107
for i = 1:length(v)
    Pr=0; vr = v0; vi=v(i);
    gamma_v =@(v) g0.*rho0.*v;
    %xi = @(v) exp(-trapz(v,gamma_v(v)./v));
    integrandxi = @(v) gamma_v(v)./v;
    xi = @(vi) exp(-integral(integrandxi,v0,vi));


    %General form if want to use arbitrary Hugoniot
    PH_v = @(v) c0.^2.*(v0-v)./(v0-s.*(v0-v)).^2;
    dPHdV_v = @(v) -c0.^2.*(vr+s.*(vr-v))./(vr-s.*(vr-v)).^3;
    kappa = @(v) PH_v(v)-Pr+(vr-v).*dPHdV_v(v);
    %"Closed" form solution
    %kappa = @(v) -2.*rho0.^3.*s.*c0.^2.*((vr-v).^2)./(1-rho0.*s.*(vr-v)).^3;

    %TH_v = @(v) xi(vi).*(T0+0.5./cv0.*trapz(v,kappa(v)./xi(v)));
    %SH_v = @(v) 0.5.*trapz(v,kappa(v)./TH_v(v));
    %vspace = linspace(v0,vi,100)';
    %TH(i) = TH_v(vspace);
    %SH(i) = SH_v(vspace);
    
    integrandT = @(v) kappa(v)./xi(vi);
    TH_v = @(x) xi(x).*(T0+0.5./cv0.*integral(integrandT,v0,x));
    integrandS = @(v) kappa(v)./TH_v(vi);
    SH_v = @(x) 0.5.*integral(integrandS,v0,x);
    
    TH(i)=TH_v(vi);
    SH(i)=SH_v(vi);
end
end

    %Convert to Helmholtz free energy
    %EH = EH -TH.*SH;


end