function value=getState(object)

communicate(object);
fwrite(object.VISA,'RSTATE?');
value=fscanf(object.VISA);
value=strtrim(value);

end