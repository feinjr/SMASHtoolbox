% This method evaluates the debye object to obtain the Gruneisen
% coefficient as a function of density and the debye temperature
%
%     >> [gamma,theta] = calculateDebyeTemp(object);
%
% If a parameter set p is given, the object's gamma coefficients are
% overwritten
%
% created January 15, 2014 by Justin Brown (Sandia National Laboratories)
%
function [g,theta] = calculateDebyeTemp(object,rho,varargin)

gtype = object.gtype;
p = object.p;
eta = rho./object.rho0;
T0 = object.T0;

if nargin > 2
    p = varargin{1};
end

switch gtype
    
    case 1
        assert(numel(p)==1,'One parameters is expected gtype = 1');
        g0 = p(1);
        g = g0;
        theta = T0.*eta.^g0;
       
    case 2
        assert(numel(p)==3,'Three parameters are expected for gtype = 2');
        GI = p(1);
        GR = p(2);
        GT = p(3);
        g = (GR-GI).*eta.^(-GT)+GI;
        if g < -230; g = -230; end; 
        theta = T0.*eta.^GI.*exp((GR-g)./GT);
        
    case 3
        assert(numel(p)==3,'Three parameters are expected for gtype = 3');
        GI = p(1);
        A = p(2);
        B = p(3);
        g = GI + A./eta + B./eta./eta;
        theta = T0.*eta.^(-GI).*exp(A.*(1-1./eta)+B/2.*(1-1./eta./eta));
    
    case 4
        assert(numel(p)==2,'Two parameters are expected for gtype = 4');
        GI = p(1);
        GR = p(2);
        g = GR./eta + GI.*(1-1./eta).^2;
        theta = T0.*eta.^GI.*exp(GR-g-GI./2.*(1-1./eta./eta));
    
    case 5
        assert(numel(p)==2,'Two parameters are expected for gtype = 5');
        GI = p(1);
        GR = p(2);
        g = GR./eta + GI.*(1-1./eta);
        theta = T0.*eta.^GI.*exp(GR-g);
        
        
    otherwise
        error('Unable to evaluate gamma');
end