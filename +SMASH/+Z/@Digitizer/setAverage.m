function setAverage(object,value)

assert(isnumeric(value) && isscalar(value) && (value>=0),...
    'ERROR: invalid number of averages');

communicate(object);

if value < 2
    fwrite(object.VISA,'ACQUIRE:AVERAGE OFF');
    return
end

fwrite(object.VISA,'ACQUIRE:AVERAGE ON');
command=sprintf('ACQUIRE:AVERAGE:COUNT %d',value);
fwrite(object.VISA,command);

new=getAverage(object);
if new ~= value
     warning('SMASH:Digitizer',...
        'Invalid number of averages set to the nearest allowed value');
end

end