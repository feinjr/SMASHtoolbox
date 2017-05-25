 function GetLampWavelengths(obj,centerWavelength,grating,WaveDirection)
            %The GetLampWavelengths method uses a measured HgNe lamp
            %spectrum to obtain the relevant wavelengths. The HgNe lamp
            %spectrum is plotted with the wavelength image in the
            %spectroscopy class. The user is prompted to shift the spectrum
            %along the HgNe spectrum to match the peaks. When the peaks are
            %satifactorily aligned, the can exit the GUI and the
            %KnownWavelengthLines property will be set to the selected peaks.
            %See the MatchWavelength function help for more details.
            %grating is the g/mm, centerWavelength is the spectrometer
            %setting in nm, WaveDirection is the direction of wavelength on
            %the image (X or Y).
            %Example obj.GetLampWavelengths(600,150,'Y')
            
            obj.WavelengthDirection=WaveDirection;
            close all
            f=figure;
            ax=gca;
            ScaledImage(f,ax,obj.WavelengthImage);
            title('Select wavelength cal region')
            [ROI,~]=DrawRectangle();
            [x,y]=Lineout(obj.WavelengthImage,ROI(1),ROI(2),ROI(3),ROI(4),WaveDirection);
            obj.KnownWavelengthLines=MatchWavelength(x,y,centerWavelength,grating);         
            obj.KnownWavelengthLines=transpose(obj.KnownWavelengthLines);
        end