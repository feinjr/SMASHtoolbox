function [WavePolyFitCoeff,wavelength]=CalibrateWavelengthLine(x,KnownLines,PeakLocations)
if length(PeakLocations)<3
    Order=1;
else
    Order=2;
end
WavePolyFitCoeff=polyfit(PeakLocations,KnownLines,Order);
wavelength=polyval(WavePolyFitCoeff,x);
end



