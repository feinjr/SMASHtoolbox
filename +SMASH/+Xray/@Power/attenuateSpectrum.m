%
%
% created March 01, 2017 by Adam Harvey-Thompson (Sandia National Laboratories)
%
% Calculates energy absorbed by the diode element based on calibrations
function object = attenuateSpectrum(object)

TempSpectrum = object.Spectrum.Data;
TempAbsorptionCurve = object.AbsorptionCurve.Data;
TempGrid = object.Spectrum.Grid;

AttenuatedSpectrum = TempSpectrum.*TempAbsorptionCurve;

object = SMASH.SignalAnalysis.Signal(TempGrid,AttenuatedSpectrum);

end
