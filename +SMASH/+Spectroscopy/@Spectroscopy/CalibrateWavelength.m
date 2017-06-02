   function CalibrateWavelength(obj,KnownLines,WaveDirection)
            %The CalibrateWavelength method uses given wavelength lines,
            %and the direction to calibrate the wavelength. The user is
            %prompted to select an area where the wavelength should be
            %calibrated. Each pixel row/column in the time dimension is
            %calibrated for wavelength, and the resulting polynomial
            %coefficients are stored in the property, WavePolyFitCoeff,
            %where the index corresponds to the pixel row/column in the
            %time dimension. 
            %
            %If the selected area is less then the size of
            %the image in the time direction, the first and last calculated
            %polynomial coefficients are appended to the beginning and end
            %of the wavelength calibration array so that the length of the
            %wavelength calibration array is equal to the length of the
            %image in the time dimension.
            %Example: obj.CalibrateWavelength(KnownLines,'Y')
            
            close all
            obj.WavelengthDirection=WaveDirection;
            obj.KnownWavelengthLines=KnownLines;
            
            f=figure;
            ax=axes;
            ScaledImage(f,ax,obj.WavelengthImage);
            ax.YLabel.String='Pixel';
            ax.XLabel.String='Pixel';
            
            title('Select region to calibrate for wavelength')
            [ROI,~]=DrawRectangle();
            obj.WavePolyFitCoeff=CalibrateWavelengthMatrix(obj.WavelengthImage,ROI,obj.KnownWavelengthLines,obj.WavelengthDirection);                 
        end