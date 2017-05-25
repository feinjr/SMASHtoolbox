function [PeakLocations,PeakWidths]=GetResolution(obj,x,y)
%The GetResolution method returns the width and wavelengths of
%the wavelength calibration lines in order to determine the
%resolution as a function of wavelength.
[PeakLocations,PeakWidths]=Resolution(x,y,obj.KnownWavelengthLines);
end