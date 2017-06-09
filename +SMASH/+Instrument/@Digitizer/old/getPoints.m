function value=getPoints(object)

communicate(object);

fwrite(object.VISA,'ACQUIRE:POINTS:ANALOG?');
value=strtrim(fscanf(object.VISA));
value=sscanf(value,'%g');

end