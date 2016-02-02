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
d = 1e-2*options.Distance;

if isfield(options,'SignalLimits')
    Slims = options.SignalLimits;
else
    Slims = [min(t), max(t)];
end

dt = t(2)-t(1);

ttemp = Slims(1):dt:Slims(2);

% Import IRF
IRF = options.InstrumentResponse;
if isempty(IRF)
    tIRF = -10e-9:dt:10e-9;
    IRF_interp = zeros(size(tIRF));
    IRF_interp(round(length(tIRF)/2)) = 1;
else
    [~,I] = max(IRF.Data);
    IRF = shift(IRF,-IRF.Grid(I));
    IRF = scale(IRF,1e-9);
    tIRF = -max(IRF.Grid):dt:max(IRF.Grid);
    IRF_interp = interp1(IRF.Grid,IRF.Data,tIRF,'linear',0);
end

% Define burn history
BW = options.BurnWidth;
if isempty(BW)
    history = IRF_interp;
else
    sigma = BW/2.35482;
    history = exp(-tIRF.^2/2/sigma^2);
end

% Calculate Spectrum
[Io, Ebin] = Ballabio(temperature,options.Earray,options.Reaction);

% detector properties
cL = 2.99792458e8; %speed of light in m/s
tL = d/cL;
mn = 1.6749286e-27; %neutron mass in kg

beta = tL./(ttemp-bangtime);
gamma = 1./sqrt(1-beta.^2);
Jacobian = (mn/tL)*gamma.^3.*beta.^3;
Energy = cL^2*mn*(gamma-1);

% import LO vs. neutron energy
LO = options.LightOutput;
if isempty(LO)
    LOI = ones(size(Energy));
else
    LOI = interp1(1.6022e-13*LO.Grid,LO.Data,Energy);
end

fE = interp1(Ebin*1.6022e-13,Io,Energy,'linear',0);
temp = conv(fE.*abs(Jacobian).*LOI,IRF_interp,'same');
dNdt_temp = conv(temp,history,'same');
dNdt_temp = dNdt_temp/max(dNdt_temp);

dNdt = interp1(ttemp,dNdt_temp,t);

end

