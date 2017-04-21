function value=getBandwidth(object)

forceSettings(object);

fopen(object.VISA);
CU=onCleanup(@() fclose(object.VISA));

fwrite(object.VISA,'ACQUIRE:BANDWIDTH?');
value=strtrim(fscanf(object.VISA));
value=sscanf(value,'%g');

end