% This method evaluates a Vinet object at specified density and temperature
%
%     >> [P, E, S] = evaluate(object,rho,T);
%
% using the model object. The pressure, Helmholtz free energy, and entropy
% are returned.
%
% If a parameter set p is given, the object's cold curve parameters are
% overwritten
%
%    >> [P, E, S] = evaluate(object,rho,T,[B0,BP0,d2,d3,...]);
%
% See also Vinet, evaluate, calibrate
%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function [P,E,S] =calculateVinet(object,rho,T,varargin)

rho=rho(:);
T=T(:);

rho0=object.rho0;
T0=object.T0;
a0=object.alpha;
cv0=object.cv;
B0=object.B0;
BP0=object.BP0;
dn = object.d;

if nargin > 3
    p = varargin{1};
    B0 = p(1);
    BP0 = p(2);
    dn = [];
    if length(p)>2
        dn = p(3:end);
    end
end

%Calculate reference curve
x=(rho0./rho).^(1/3);
z=1-x;
eta0 = 3.0/2.0*(BP0-1);
LeadTerm = (3.*B0./(x.^2)).*z.*exp(eta0.*z);
Pref = LeadTerm;

    %Higher order terms
    for i=1:length(dn);
         Pref = Pref + LeadTerm.*dn(i).*z.^(i+1);
    end

%Total EOS
P=Pref+a0*B0*(T-T0);
    
   
%Entropy and Energy calculations have not been verified!
S=zeros(size(P));
E=zeros(size(P));
% S0=0;
% S = S0+a0.*B0.*(1/rho-1/rho0)+cv0.*log(T./T0);
% 
% d(1)=1.0; d(2)=0.0; d=[d dn];
% sumZ =0; f(1)=d(1)-(2)/eta0*d(1);
% for i=2:length(d)
%     if i ==length(d)
%         f(i)=d(i);
%     else
%         f(i)=d(i)-(i+2)/eta0*d(i+1);
%     end
%     sumZ=sumZ+f(i).*z.^(i-1);
% end
% f0=f(1);
% 
% U = 9*B0/(rho0*eta0^2)*(f0-exp(eta0*z*(f0+sumZ)))-a0*B0/rho0*(1-x.^3)*T0+cv0*(T-T0);
% E=U-T.*S;


end