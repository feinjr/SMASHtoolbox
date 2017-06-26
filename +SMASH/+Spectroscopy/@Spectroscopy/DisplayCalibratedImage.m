%The DisplayCalibratedImage method uses the wavelength and polynomial
%coefficients to put the image on a time and wavelength axis.
%The wavelength coefficents are the average of the coefficents
%for the full image. Both time and wavelength calibration must
%be completed before using this method.
%Example: DisplayCalibratedImage(dataImage)
function DisplayCalibratedImage(obj,image)
if isempty(obj.WavePolyFitCoeff)==1 || isempty(obj.TimePolyFitCoeff)==1
    error('Wavelength or Time Calibration not found')
end
if obj.TimeDirection=='X'
    wavelength=polyval(mean(obj.WavePolyFitCoeff),1:size(image,1));
    time=polyval(obj.TimePolyFitCoeff ,1:size(image,2));
    
    f=figure;
    ax=axes;
    ScaledImage(f,ax,image,'X',time,'Y',wavelength);
    
    xlabel('Time (ns)')
    ylabel('Wavelength (nm)')
    
elseif obj.TimeDirection=='Y'
    wavelength=polyval(mean(obj.WavePolyFitCoeff),1:size(image,2));
    time=polyval(obj.TimePolyFitCoeff,1:size(image,1));
    
    f=figure;
    ax=axes;
    ScaledImage(f,ax,image,'X',wavelength,'Y',time);
    
    xlabel('Wavelength (nm)')
    ylabel('Time (ns)')
end
end