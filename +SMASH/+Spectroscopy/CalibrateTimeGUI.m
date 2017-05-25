%The CalibrateTimeGUI function takes image data, impulse time, comb frequency (in
%MHz), and Time Direction ('X', or 'Y') and returns the polynomial
%coefficents of the fit. The user is prompted to select the comb region,
%and an intial threshold of 1/4 the maximum and an initial prominence of 20
%are used as defaults for the fit. The user is prompted to accept these
%defaults or change them. The fit is then applied, if it looks good, an
%impulse region is selected and the same prompts are applied. If the fit is
%not good then the user is prompted to change the thresholds and
%prominences.
%
%Example: CalibratedTimeCoeff=CalibrateTimeGUI(image,3100,35,'X')

%created May 12, 2017 by Sonal Patel (Sandia National Laboratories)

function CalibratedTime=CalibrateTimeGUI(pic,ImpulseTime,CombFrequency,TimeDirection)
    disp('Select Comb Region')
    CombPeaks=SelectTimeRegion(1000, 'Select Comb Region');
    disp('Select Impulse Region')
    ImpulsePeak=SelectTimeRegion(1,'Select Impulse Region');
    
    TimeDiff=(1/CombFrequency)*1000.0;
    CombPeakTime=(1:length(CombPeaks))*TimeDiff;
    CombPeakTime=CombPeakTime(:);
    CombPeaks=CombPeaks(:);
    
    TimePolyFit=polyfit(CombPeaks,CombPeakTime,2);
    ImpulseUnshiftedTime=polyval(TimePolyFit,ImpulsePeak);
    Shift=ImpulseTime-ImpulseUnshiftedTime;
    TimePolyFit(end)=TimePolyFit(end)+Shift;
    CalibratedTime=TimePolyFit;
   
    function PeakLocations=SelectTimeRegion(NPeaks,Title)
        close all
        
        f=figure;
        ax=axes;
        ScaledImage(f,ax,pic);
            
        title(Title);
        [ROI,~]=DrawRectangle();
        [x,y]=Lineout(pic,ROI(1),ROI(2),ROI(3),ROI(4),TimeDirection);
        [Type,InterpolatedBackground,ReturnPoints]=BackgroundSubtractPlot(x,y);
        y=y-InterpolatedBackground;
        y(y<0)=0; 
        [FinalFit,PeakLocations,PeakIndexGuess,PeakWidths,Amplitude]=TryFit(x,y,NPeaks,max(y)/4.0,20);
    end
    
    
end