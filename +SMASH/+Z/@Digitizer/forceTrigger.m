function forceTrigger(object)

if numel(object) > 1
    for n=1:numel(object)
        forceTrigger(object(n));
    end
    return
end

assert(strcmp(object.VISA.Status,'open'),...
    'ERROR: cannot communicate with a closed digitizer');
fwrite(object.VISA,'TRIGGER:SWEEP AUTO');
pause(0.2);
communicate(object);


end