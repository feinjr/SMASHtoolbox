function WavePolyFitCoeff=CalibrateWavelengthMatrix(pic,ROI,KnownWavelengthLines,direction)
    if direction=='Y'
        TimeStart=ROI(3);
        TimeEnd=ROI(4);
        [x,y]=Lineout(pic,ROI(1),ROI(2),ROI(3),ROI(3)+1,direction);
    elseif direction=='X'
        TimeStart=ROI(1);
        TimeEnd=ROI(2);
        [x,y]=Lineout(pic,ROI(1),ROI(1)+1,ROI(3),ROI(4),direction);
    end
    WavePolyFitCoeff=[];
    [Type,InterpolatedBackground,ReturnPoints]=BackgroundSubtractPlot(x,y);
    y=y-InterpolatedBackground;
    y(y<0)=0; 
    [~,~,PeakIndexGuess,PeakWidthsGuess,~]=TryFit(x,y,length(KnownWavelengthLines),0,20);
    lastwarn('');
    for i=TimeStart:1:TimeEnd
        disp(i)
        if direction=='Y'
            [x,y]=Lineout(pic,ROI(1),ROI(2),i,i+1,direction);
        elseif direction=='X'
            [x,y]=Lineout(pic,i,i+1,ROI(3),ROI(4),direction);
        end
        if strcmp(Type,'Flat')
            InterpolatedBackground=BackgroundSubtract(x,y,'Flat',ReturnPoints);
        elseif strcmp(Type,'PolyFit')
            xpoint=x(ReturnPoints(:,3));
            ypoint=y(ReturnPoints(:,3));
            points=[xpoint,ypoint];
            InterpolatedBackground=BackgroundSubtract(x,y,'Polynomial',points);
        elseif strcmp(Type,'MedianFit')
            InterpolatedBackground=BackgroundSubtract(x,y,'MedianFilter',ReturnPoints);
        end
        y=y-InterpolatedBackground;
        y(y<0)=0;
        [~,PeakLocations,~,~]=FitNPeaks2(x,y,PeakIndexGuess,PeakWidthsGuess);
        [~, msgid] = lastwarn;
        if strcmp(msgid,'')==0
            [~,PeakLocations,PeakIndexGuess,PeakWidthsGuess,~]=TryFit(x,y,length(KnownWavelengthLines),0,20);
            WavePolyFitCoeff(end+1,:)=CalibrateWavelengthLine(x,KnownWavelengthLines,PeakLocations);
            lastwarn('');
        else
            WavePolyFitCoeff(end+1,:)=CalibrateWavelengthLine(x,KnownWavelengthLines,PeakLocations);
        end
    end
    FirstCoeff=ones(TimeStart-1,size(WavePolyFitCoeff,2)).*WavePolyFitCoeff(1,:);
    LastCoeff=ones(size(pic,2)-TimeEnd,size(WavePolyFitCoeff,2)).*WavePolyFitCoeff(end,:);
    WavePolyFitCoeff=[FirstCoeff;WavePolyFitCoeff;LastCoeff];    
end
