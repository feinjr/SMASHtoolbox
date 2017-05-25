function DisplayCalibratedImage(obj,image)
%The DisplayCalibratedImage method uses the wavelength and polynomial
%coefficients to put the image on a time and wavelength axis.
%The wavelength coefficents are the average of the coefficents
%for the full image. Both time and wavelength calibration must
%be completed before using this method.
%Example: DisplayCalibratedImage(dataImage)
if isempty(obj.WavePolyFitCoeff)==1 || isempty(obj.TimePolyFitCoeff)==1
    error('Wavelength or Time Calibration not found')
end
PlotCalibratedImage(image,...
    obj.TimePolyFitCoeff,obj.WavePolyFitCoeff,obj.TimeDirection)
end
