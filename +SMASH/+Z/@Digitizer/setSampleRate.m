function setSampleRate(object,value)

assert(isnumeric(value) && isscalar(value) && (value>0),...
    'ERROR: invalid sample rate');

communicate(object);

command=sprintf('ACQUIRE:SRATE:ANALOG %g',value);
fwrite(object.VISA,command);
new=getSampleRate(object);

if new ~= value
    warning('SMASH:Digitizer',...
        'Invalid sample rate set to the nearest allowed value');
end

end