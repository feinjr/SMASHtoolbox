function setPoints(object,value)

assert(isnumeric(value) && isscalar(value) && (value>0),...
    'ERROR: invalid number of points');

communicate(object);

command=sprintf('ACQUIRE:POINTS:ANALOG %d',value);
fwrite(object.VISA,command);

new=getPoints(object);
if new ~= value
     warning('SMASH:Digitizer',...
        'Invalid number of points set to the nearest allowed value');
end

end