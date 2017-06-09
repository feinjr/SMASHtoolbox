function setTrigger(object,value)

% manage input
assert(isstruct(value),'ERROR: invalid trigger setting');

% apply settings
communicate(object);

command=sprintf('TRIGGER:EDGE:SOURCE %s',value.Source);
fwrite(object.VISA,command);

command=sprintf('TRIGGER:EDGE:SLOPE %s',value.Slope);
fwrite(object.VISA,command);

command=sprintf('TRIGGER:LEVEL %s, %g',value.Source,value.Level);
fwrite(object.VISA,command);

command=sprintf('TIMEBASE:REFERENCE %s','LEFT');
%fwrite(object.VISA,command);

command=sprintf('TIMEBASE:POSITION %g',value.Start);
fwrite(object.VISA,command);

end