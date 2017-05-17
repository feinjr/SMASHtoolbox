function [ object ] = correctMagnification( object )
% This function corrects for the instrument magnification and puts the
% scale in cm

object.Measurement = scale(object.Measurement,'Grid1',...
    1e-1/object.Settings.Magnification);
object.Measurement = scale(object.Measurement,'Grid2',...
    1e-1/object.Settings.Magnification);
object.Measurement.GraphicOptions.AspectRatio = 'equal';
object.Measurement.GraphicOptions.YDir = 'normal';

end

