function forceTrigger(object)

assert(strcmp(object.VISA.Status,'open'),...
    'ERROR: cannot communicate with a closed digitizer');
fwrite(object.VISA,'TRIGGER:SWEEP AUTO');
pause(0.2);
communicate(object);


end