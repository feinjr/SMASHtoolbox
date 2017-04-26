function communicate(object)

assert(strcmp(object.VISA.Status,'open'),...
    'ERROR: cannot communicate with a closed digitizer');

fwrite(object.VISA,':ACQUIRE:MODE RTIME');
fwrite(object.VISA,':ACQUIRE:SRATE:ANALOG:AUTO OFF');
fwrite(object.VISA,':ACQUIRE:INTERPOLATE OFF');
fwrite(object.VISA,':TRIGGER:MODE EDGE');
fwrite(object.VISA,':TRIGGER:SWEEP TRIGGERED');
fwrite(object.VISA,'WAVEFORM:VIEW ALL')

end