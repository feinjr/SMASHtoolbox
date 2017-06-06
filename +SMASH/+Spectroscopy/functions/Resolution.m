function [PeakLocations,PeakWidths]=Resolution(x,y,KnownWavelengthLines)
[~,InterpolatedBackground,~]=BackgroundSubtractPlot(x,y);
y=y-InterpolatedBackground;
[~,PeakLocations,~,PeakWidths,~]=TryFit(x,y,length(KnownWavelengthLines),0,20);
figure
u=plot(PeakLocations,PeakWidths,'k');
u.Marker='o';
u.MarkerFaceColor='k';
u.MarkerSize=3;
xlabel('Wavelength (nm)');
ylabel('Resolution (nm)');
title('Spectral Resolution');
end