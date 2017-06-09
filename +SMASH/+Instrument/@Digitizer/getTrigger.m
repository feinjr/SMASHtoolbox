function value=getTrigger(object)

communicate(object);

fwrite(object.VISA,'TRIGGER:EDGE:SOURCE?');
value.Source=strtrim(fscanf(object.VISA));

fwrite(object.VISA,'TRIGGER:EDGE:SLOPE?');
value.Slope=strtrim(fscanf(object.VISA));

command=sprintf('TRIGGER:LEVEL? %s',value.Source);
fwrite(object.VISA,command);
temp=strtrim(fscanf(object.VISA));
value.Level=sscanf(temp,'%g');

%
fwrite(object.VISA,'TIMEBASE:REFERENCE LEFT');
%fwrite(object.VISA,'TIMEBASE:REFERENCE?');
%value.ReferenceType=strtrim(fscanf(object.VISA));

fwrite(object.VISA,'TIMEBASE:POSITION?');
temp=strtrim(fscanf(object.VISA));
value.Start=sscanf(temp,'%g');

end