function value=getSampleRate(object)

communicate(object);

fwrite(object.VISA,'ACQUIRE:SRATE:ANALOG?');
value=strtrim(fscanf(object.VISA));
value=sscanf(value,'%g');

end