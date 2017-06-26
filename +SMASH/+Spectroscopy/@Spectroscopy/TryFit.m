%The TryFit function is a GUI to quickly try different thresholds and
%prominences to fit multipeak data. A  gaussian fit is applied to each
%peak, and the location of these peaks are used to calibrate the wavelength
%and time for the spectroscopy class.

%The function can be used to fit any number of peaks. Inputs are x and y
%data, the number of peaks to fit (NPeaks), the default threshold and default
%prominence. The user is prompted to accept these defaults or change them.
%The fit is then applied. If the fit is not good then the user is prompted
%to change the thresholds and prominences again.
%
%The fit is applied starting from the tallest peak and continues fitting
%peaks until NPeaks is reached or the next tallest peak is below the peak
%threshold. If an unknown number of peaks need to be fitted, select a large
%NPeaks. If an exact number of peaks need to be fitted, set peakThreshold
%to zero.

%created May 12, 2017 by Sonal Patel (Sandia National Laboratories)

function [FinalFit,PeakLocations,PeakIndexGuess,PeakWidths,Amplitude]=TryFit...
    (x,y,defaultNPeaks,defaultThreshold,defaultProminence,varargin)

p=inputParser;
addRequired(p,'x');
addRequired(p,'y');
addRequired(p,'defaultThreshold');
addRequired(p,'defaultProminence');
addRequired(p,'defaultNPeaks');

addOptional(p,'FitSpeed','Fast');
parse(p,x,y,defaultNPeaks,defaultThreshold,defaultProminence,varargin{:});
p.Results.FitSpeed

tryagain=0;
while tryagain==0
    close all
    u=plot(x,y,'k');
    u.Marker='o';
    u.MarkerFaceColor='k';
    u.MarkerSize=3;
    title(strcat('Default threshold is: ',{' '},string(defaultThreshold),'.',{' '},'Enter to Continue'));
    
    disp(strcat('Default threshold is: ',string(defaultThreshold)));    
    Threshold=input('Enter if this is okay, or enter new threshold: ');
    
    title(strcat('Default prominence is: ',{' '},string(defaultProminence),'.',{' '},'Enter to Continue'));
    disp(strcat('Default prominence is: ',string(defaultProminence)));
    Prominence=input('Enter if this is okay, or enter new Prominence: ');
    
    if isempty(Threshold)==1
        Threshold=defaultThreshold;
    end
    if isempty(Prominence)==1
        Prominence=defaultProminence;
    end
    [PeakIndexGuess,~,PeakWidthGuess]=FindPeaks(x,y,defaultNPeaks,Threshold,Prominence);
    
    if  strcmp(p.UsingDefaults, 'FitSpeed')==0
        [FinalFit,PeakLocations,PeakWidths,Amplitude]=FitNPeaks(x,y,PeakIndexGuess,PeakWidthGuess);
    else
        [FinalFit,PeakLocations,PeakWidths,Amplitude]=FitNPeaks2(x,y,PeakIndexGuess,PeakWidthGuess);
    end
    hold on
    plot(x,FinalFit,'r')
    disp('Number of peaks found: ')
    disp(length(PeakLocations))
    again=input('Hit enter if the fit is good. Hit 0 to try again: ');
    if isempty(again)==1
        tryagain=1;
    end
end