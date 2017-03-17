function [ object ] = correctMagnification( object )
% This function corrects for the instrument magnification and puts the
% scale in cm

object.Measurement = scale(object.Measurement,'Grid1',...
    1e-4/object.Settings.Magnification);
object.Measurement = scale(object.Measurement,'Grid2',...
    1e-4/object.Settings.Magnification);

end

