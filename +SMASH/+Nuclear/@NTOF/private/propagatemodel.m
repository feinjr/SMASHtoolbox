function [ dNdt ] = propagatemodel( bangtime, temperature , t, options)
%
%   Inputs: bangtime - estimated neutron bangtime in seconds
%           temperature - ion temperature in keV
%           options - structure containing various other information
%               Detector - label determining which nTOF location to use
%               InstrumentResponse - Signal object containing the IRF
%               BurnWidth - burn duration in seconds
%               Earray - [Emin, Emax, num. pts] in MeV, for calculating 
%                        neutron spectrum    
%               LightOutput - Signal object containing LO curve vs. energy
%               Reaction - string to tell what reaction to calc. 'DDn' or
%               'DT'
%%
switch options.Detector
    case '7 m'
        d = 6.896;
    case '8 m'
        d = 7.86;
    case '9 m'
        d = 9.44;
    case '11 m'
        d = 11.46;
    case '25 m'
        d = 25.1;
end

dt = t(2)-t(1);
% Import IRF
IRF = options.InstrumentResponse;
[~,I] = max(IRF.Data);
IRF = shift(IRF,-IRF.Grid(I));

IRF = scale(IRF,1e-9);
tIRF = -max(IRF.Grid):dt:max(IRF.Grid);
IRF_interp = interp1(IRF.Grid,IRF.Data,tIRF,'linear',0);

% Define burn history
BW = options.BurnWidth;
sigma = BW/2.35482;
history = exp(-tIRF.^2/2/sigma^2);

% Calculate Spectrum
[Io, Ebin] = Ballabio(temperature,options.Earray,'DDn');

% detector properties
cL = 2.99792458e8; %speed of light
tL = d/cL;
mn = 1.6749286e-27; %neutron mass in kg

beta = tL./(t-bangtime-0*25e-9);
gamma = 1./sqrt(1-beta.^2);
Jacobian = (mn/tL)*gamma.^3.*beta.^3;
Energy = cL^2*mn*(gamma-1);

% import LO vs. neutron energy
LO = options.LightOutput;
LOI = interp1(1.6022e-13*LO.Grid,LO.Data,Energy);

fE = interp1(Ebin*1.6022e-13,Io,Energy,'linear',0);
temp = conv(fE.*abs(Jacobian).*LOI,IRF_interp,'same');
dNdt = conv(temp,history,'same');
dNdt = dNdt/max(dNdt);

end

