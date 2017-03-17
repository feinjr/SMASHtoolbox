function [ object ] = correctFade( object )
% This function corrects for image plate fade given the time between
% exposure and scanning in minutes.  This time is located in the
% object.Settings.DecayTime property

fade = @(t) 0.184 + 0.264*exp(-t/34.5) + 0.57*exp(-t/5313);

if isempty(object.Settings.DecayTime)
    factor = 1;
else
    factor = fade(object.Settings.DecayTime);    
end
object.Measurement = object.Measurement/factor;

end

