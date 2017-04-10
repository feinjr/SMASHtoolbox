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
    SpectrumData = object.Spectrum.Data(:,1);
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

SignalNumber = size(object.Settings,2)-1;
Signals = 1:SignalNumber;

for i=Signals;

AbsorptionData1 = object.AbsorptionCurve.Data(:,i);

%Put absorption curve on same grid as Spectrum

AbsorptionData = interp1(AbsorptionGrid,AbsorptionData1,SpectrumGrid);
AttenuatedSpectrum = AbsorptionData.*SpectrumData;

%% Integrate absorbed spectrum over all energies

IntegratedSpectrum = trapz(SpectrumGrid,AttenuatedSpectrum);

%% Normalize spectrum wrt element energy

NormFactor = cell2mat(object.AnalysisSummary(9,i+1))/IntegratedSpectrum;

object.AnalysisSummary{5,i+1} = NormFactor;

NormSpectrum = SpectrumData.*NormFactor;

%% Make matrix of attenuated spectra

AttenuatedSpectra(:,i) = AttenuatedSpectrum.*NormFactor;

%% Integrate normalized spectrum over all energies and spectrum bounds

IntegratedNormSpectrum = trapz(SpectrumGrid,NormSpectrum);

[~,SpectrumStartInd]=min(abs(SpectrumGrid-EnergyMin));
[~,SpectrumEndInd]=min(abs(SpectrumGrid-EnergyMax));

IntegratedBoundSpectrum = trapz(SpectrumGrid(SpectrumStartInd:SpectrumEndInd),NormSpectrum(SpectrumStartInd:SpectrumEndInd));

object.AnalysisSummary{6,i+1} = [SpectrumGrid(1) SpectrumGrid(end); SpectrumGrid(SpectrumStartInd) SpectrumGrid(SpectrumEndInd)];
object.AnalysisSummary{10,i+1} = IntegratedNormSpectrum;
object.AnalysisSummary{11,i+1} = IntegratedBoundSpectrum;
end

%% Save input spectrum and normalized, attenuated spectra
SpectrumGroup = SMASH.SignalAnalysis.SignalGroup(SpectrumGrid,AttenuatedSpectra);
object.Spectrum = SMASH.SignalAnalysis.SignalGroup(SpectrumGrid,SpectrumData);
object.Spectrum = gather(object.Spectrum,SpectrumGroup);

object.Spectrum.DataLabel = 'Energy (J/eV)';
object.Spectrum.GridLabel = 'Photon energy (eV)';
object.Spectrum.Legend{1} = 'Input spectrum';
[object.Spectrum.Legend{2:end}] = deal(object.AnalysisSummary{1,2:end});

end

