function setTrigger(object,value)

% manage input
assert(isstruct(value),'ERROR: invalid trigger setting');

% apply settings
communicate(object);

if ischar(value.Source)
    value.Source=upper(value.Source);
end
switch value.Source
    case {'CHANNEL1' 'CH1' '1' 1}
        value.Source='CHANNEL1';
    case {'CHANNEL2' 'CH2' '2' 2}
        value.Source='CHANNEL2';
    case {'CHANNEL3' 'CH3' '3' 3}
        value.Source='CHANNEL3';
    case {'CHANNEL4' 'CH4' '4' 4}
        value.Source='CHANNEL4';
    otherwise
        value.Source='AUXILIARY';
end
command=sprintf('TRIGGER:EDGE:SOURCE %s',value.Source);
fwrite(object.VISA,command);

command=sprintf('TRIGGER:EDGE:SLOPE %s',value.Slope);
fwrite(object.VISA,command);

command=sprintf('TRIGGER:LEVEL %s, %g',value.Source,value.Level);
fwrite(object.VISA,command);

command=sprintf('TIMEBASE:REFERENCE %s','LEFT');
fwrite(object.VISA,command);

command=sprintf('TIMEBASE:POSITION %g',value.Start);
fwrite(object.VISA,command);

end