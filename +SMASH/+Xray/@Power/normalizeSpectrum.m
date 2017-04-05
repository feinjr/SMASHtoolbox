%
%
%
% Created March 16, 2017 by Adam Harvey-Thompson (Sandia National Laboratories)
%
%
function object = normalizeSpectrum(object,varargin)

%% Set minimum energy to be first input argument, maximum energy as 2nd input argument

if (nargin>1)  && isobject(varargin{1})
    SpectrumGrid = varargin{1}.Grid;
    SpectrumData = varargin{1}.Data;
    numarg = 3;
else
    SpectrumGrid = object.Spectrum.Grid;
    SpectrumData = object.Spectrum.Data;
    numarg = 2;
end

if (nargin==numarg) && isnumeric(varargin{numarg-1})
    EnergyMin = varargin{numarg-1};
    EnergyMax = 0;
elseif  (nargin==numarg+1) && isnumeric(varargin{numarg-1}) && isnumeric(varargin{numarg});
    EnergyMin = varargin{numarg-1};
    EnergyMax = varargin{numarg};    
else
    EnergyMin = 0;
    EnergyMax = max(SpectrumGrid);
end



AbsorptionGrid = object.AbsorptionCurve.Grid;

SignalNumber = size(object.Settings,2)-1
Signals = 1:SignalNumber
j=0
for i=Signals

AbsorptionData = object.AbsorptionCurve.Data(:,i);

%Put absorption curve on same grid as Spectrum

AbsorptionData = interp1(AbsorptionGrid,AbsorptionData,SpectrumGrid);
AbsorptionGrid = SpectrumGrid;

AttenuatedSpectrum = AbsorptionData.*SpectrumData;

%% Integrate absorbed spectrum over all energies

IntegratedSpectrum = trapz(SpectrumGrid,AttenuatedSpectrum);

%% Normalize spectrum wrt element energy

NormFactor = object.SourceEnergy/IntegratedSpectrum;

object.SpectrumInfo.NormalizationFactor = NormFactor;

NormSpectrum = SpectrumData*NormFactor;

%% Input spectra into object.Spectrum

Spectra = [SpectrumData NormSpectrum AttenuatedSpectrum*NormFactor];

object.Spectrum = SMASH.SignalAnalysis.SignalGroup(SpectrumGrid,Spectra);

%% Integrate normalized spectrum over all energies and spectrum bounds

IntegratedNormSpectrum = trapz(SpectrumGrid,NormSpectrum);

[~,SpectrumStartInd]=min(abs(SpectrumGrid-EnergyMin));
[~,SpectrumEndInd]=min(abs(SpectrumGrid-EnergyMax));

IntegratedBoundSpectrum = trapz(SpectrumGrid(SpectrumStartInd:SpectrumEndInd),NormSpectrum(SpectrumStartInd:SpectrumEndInd));

object.SpectrumInfo.SpectrumBounds = [SpectrumGrid(1) SpectrumGrid(end); SpectrumGrid(SpectrumStartInd) SpectrumGrid(SpectrumEndInd)];
object.SpectrumInfo.SpectrumEnergy = [IntegratedNormSpectrum IntegratedBoundSpectrum];

end
      
end

