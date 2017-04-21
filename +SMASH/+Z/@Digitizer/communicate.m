function communicate(object)

assert(strcmp(object.VISA.Status,'open'),...
    'ERROR: cannot communicate with a closed digitizer');

fwrite(object.VISA,':ACQUIRE:MODE RTIME');
fwrite(object.VISA,':ACQUIRE:SRATE:ANALOG:AUTO OFF');
fwrite(object.VISA,':ACQUIRE:INTERPOLATE OFF');

end