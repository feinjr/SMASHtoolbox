function [PeakLocations,PeakWidths]=GetResolution(obj,x,y)
% [~,InterpolatedBackground,~]=BackgroundSubtractPlot(obj,x,y);
% y=y-InterpolatedBackground;
[~,PeakLocations,~,PeakWidths,~]=obj.TryFit(x,y,length(obj.KnownWavelengthLines),0,20,'FitSpeed','Slow');
figure
u=plot(PeakLocations,PeakWidths,'k');
u.Marker='o';
u.MarkerFaceColor='k';
u.MarkerSize=3;
xlabel('Wavelength (nm)');
ylabel('Resolution (nm)');
title('Spectral Resolution');
end