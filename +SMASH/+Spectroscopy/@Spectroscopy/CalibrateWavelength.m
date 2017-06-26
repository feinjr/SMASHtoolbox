function obj=CalibrateWavelength(obj,KnownLines,WaveDirection)
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
[ROI,~]=obj.DrawRectangle();
obj.WavePolyFitCoeff=CalibrateWavelengthMatrix(obj.WavelengthImage,ROI,obj.KnownWavelengthLines,obj.WavelengthDirection);

function WavePolyFitCoeff=CalibrateWavelengthMatrix(pic,ROI,KnownWavelengthLines,direction)
    if direction=='Y'
        TimeStart=ROI(3);
        TimeEnd=ROI(4);
        [x,y]=obj.Lineout(pic,ROI(1),ROI(2),ROI(3),ROI(3)+1,direction);
    elseif direction=='X'
        TimeStart=ROI(1);
        TimeEnd=ROI(2);
        [x,y]=obj.Lineout(pic,ROI(1),ROI(1)+1,ROI(3),ROI(4),direction);
    end
    WavePolyFitCoeff=[];
    [Type,InterpolatedBackground,ReturnPoints]=BackgroundSubtractPlot(obj,x,y);
    y=y-InterpolatedBackground;
    y(y<0)=0; 
    [~,~,PeakIndexGuess,PeakWidthsGuess,~]=obj.TryFit(x,y,length(KnownWavelengthLines),0,20);
    lastwarn('');
    for i=TimeStart:1:TimeEnd
        disp(i)
        if direction=='Y'
            [x,y]=obj.Lineout(pic,ROI(1),ROI(2),i,i+1,direction);
        elseif direction=='X'
            [x,y]=obj.Lineout(pic,i,i+1,ROI(3),ROI(4),direction);
        end
        if strcmp(Type,'Flat')
            InterpolatedBackground=obj.BackgroundSubtract(x,y,'Flat',ReturnPoints);
        elseif strcmp(Type,'PolyFit')
            xpoint=x(ReturnPoints(:,3));
            ypoint=y(ReturnPoints(:,3));
            points=[xpoint,ypoint];
            InterpolatedBackground=obj.BackgroundSubtract(x,y,'Polynomial',points);
        elseif strcmp(Type,'MedianFit')
            InterpolatedBackground=obj.BackgroundSubtract(x,y,'MedianFilter',ReturnPoints);
        end
        y=y-InterpolatedBackground;
        y(y<0)=0;
        [~,PeakLocations,~,~]=FitNPeaks2(x,y,PeakIndexGuess,PeakWidthsGuess);
        [~, msgid] = lastwarn;
        if strcmp(msgid,'')==0
            [~,PeakLocations,PeakIndexGuess,PeakWidthsGuess,~]=obj.TryFit(x,y,length(KnownWavelengthLines),0,20);
            WavePolyFitCoeff(end+1,:)=obj.CalibrateWavelengthLine(x,KnownWavelengthLines,PeakLocations);
            lastwarn('');
        else
            WavePolyFitCoeff(end+1,:)=obj.CalibrateWavelengthLine(x,KnownWavelengthLines,PeakLocations);
        end
    end
    FirstCoeff=ones(TimeStart-1,size(WavePolyFitCoeff,2)).*WavePolyFitCoeff(1,:);
    LastCoeff=ones(size(pic,2)-TimeEnd,size(WavePolyFitCoeff,2)).*WavePolyFitCoeff(end,:);
    WavePolyFitCoeff=[FirstCoeff;WavePolyFitCoeff;LastCoeff];    
end

end