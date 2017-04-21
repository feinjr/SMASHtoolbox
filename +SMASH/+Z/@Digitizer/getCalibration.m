function value=getCalibration(object)

communicate(object);

fwrite(object.VISA,'CALIBRATE:DATE?');
value.Date=strtrim(fscanf(object.VISA));

fwrite(object.VISA,'CALIBRATE:STATUS?');
value.Status=strtrim(fscanf(object.VISA));

fwrite(object.VISA,'CALIBRATE:TEMP?');
value.Temperature=strtrim(fscanf(object.VISA));

end