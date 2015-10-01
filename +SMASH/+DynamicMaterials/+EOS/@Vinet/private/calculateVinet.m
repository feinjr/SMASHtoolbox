% This method evaluates a Vinet object at specified density and temperature
%
%     >> [P, S, G] = evaluate(object,rho,T);
%
% using the model object. The pressure, entropy, and Gibb's free energy
% are returned.
%
% If a parameter set p is given, the object's cold curve parameters are
% overwritten
%
%    >> [P, S, G] = evaluate(object,rho,T,[B0,BP0,d2,d3,...]);
%
% See also Vinet, evaluate, calibrate
%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function [P,S,G] =calculateVinet(object,rho,T,varargin)

rho=rho(:);
T=T(:);

rho0=object.rho0;
T0=object.T0;
a0=object.alpha;
cv0=object.cv;
B0=object.B0;
BP0=object.BP0;
dn = object.d;
s0 = object.s0;
e0 = object.e0;

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
    
   
%Entropy
S=zeros(size(P));
S0=0;
S = S0+a0.*B0.*(1./rho-1./rho0)+cv0.*log(T./T0);



%Energy
U=zeros(size(P));
E=zeros(size(P));
G=zeros(size(P));
d(1)=1.0; d(2)=0.0; d=[d dn];
f=zeros(size(d));
f(1)=1;
sumZ = f(1);
for i=2:length(d)
    if i == length(d)
        f(i)=d(i);
    else
        f(i+1)=d(i)-f(i).*eta0./(i+1);
    end
    sumZ=sumZ+f(i).*z.^(i-1);
end

%Internal
%U = 9.*B0./(rho0.*eta0.^2).*(1-exp(eta0.*z))+a0.*B0*T0.*(1./rho0-1./rho)+cv0.*(T-T0)+e0;
U = 9.*B0./(rho0.*eta0.^2).*(f(1)-exp(eta0.*z.*(f(1)+sumZ)))-a0.*B0./rho0*(1-x.^3).*T0+cv0.*(T-T0)+e0;
%Helmholtz
F=U-T.*S;
%Gibbs
G = U-T.*S+P./rho;

end