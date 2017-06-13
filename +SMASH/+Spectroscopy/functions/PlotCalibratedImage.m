function PlotCalibratedImage(image,TimeCoeff,WavelengthCoeffMatrix,TimeDirection)
   if TimeDirection=='X'
       wavelength=polyval(mean(WavelengthCoeffMatrix),1:size(image,1));
       time=polyval(TimeCoeff ,1:size(image,2));
       
       f=figure;
       ax=axes;
       ScaledImage(f,ax,image,'X',time,'Y',wavelength);
       
       xlabel('Time (ns)')
       ylabel('Wavelength (nm)')
       
   elseif TimeDirection=='Y'
       wavelength=polyval(mean(WavelengthCoeffMatrix),1:size(image,2));
       time=polyval(TimeCoeff,1:size(image,1));
       
       f=figure;
       ax=axes;
       ScaledImage(f,ax,image,'X',wavelength,'Y',time);
       
       xlabel('Wavelength (nm)')
       ylabel('Time (ns)')
   end
end