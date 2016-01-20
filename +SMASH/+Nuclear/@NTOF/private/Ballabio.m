function [Io, E] = Ballabio(Ti,Earray,reaction)
%% [Io, E] = Ballabio(Ti,Earray)
%   Calculate the DD neutron spectrum from a plasma with temperature Ti
%   using the Ballabio relativistic formula (see ref.)
%
%   Inputs:     Ti - ion temperature in keV
%               Earray - [Emin, Emax, number of elements] in MeV
%               reaction - string (DDn or DT) identifying which fusion
%                          reaction to compute
%
%   Outputs:    Io - neutron spectrum, normalized
%               E - array of energies used for calculation
%
%   Written by: Patrick Knapp, sandia national labs
%           on: 12/9/2015
%
%   Ref:  L. Ballabio et al., Nuclear Fusion, Vol 38, No 11 (1998)
%
%%
% Constants
switch reaction
    case 'DDn'
        a1 = [4.69515 -0.040729 0.47 0.81844];
        a2 = [1.7013e-3 0.16888 0.49 7.9460e-4];
        Eo = 2.4495*1e3;
        wo = 82.542;
    case 'DT'
        a1 = [5.30509, 2.4736e-3, 1.84, 1.3818];
        a2 = [5.1068e-4, 7.6223e-3, 1.78, 8.7691e-5];
        Eo = 14.021*1e3;
        wo = 177.259;        
end

% computed parameters
dE = (a1(1)/( 1 + a1(2)*Ti^a1(3) ))*Ti^( 2/3 ) + a1(4)*Ti;
dw = (a2(1)/( 1 + a2(2)*Ti^a2(3) ))*Ti^( 2/3 ) + a2(4)*Ti;
Emean = Eo + dE;
Sth = wo*(1+dw)*sqrt(Ti)/(2*sqrt(2*log(2)));

Ebar = Emean*sqrt(1-1.5*Sth/Emean^2);
S = (4/3)*Ebar*(Emean-Ebar);

% Compute spectrum
E = linspace(Earray(1),Earray(2),Earray(3));
Io = exp(-( 2*Ebar/S^2 ) * ( sqrt(1e3*E)-sqrt(Ebar)).^2 );
Io = Io/max(Io);
