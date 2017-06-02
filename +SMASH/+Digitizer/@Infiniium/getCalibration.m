function value=getCalibration(object)

communicate(object);

fwrite(object.VISA,'CALIBRATE:DATE?');
temp=strtrim(fscanf(object.VISA));
index=strfind(temp,',');
value.Date.TimeScale=temp(1:index-1);
value.Date.Regular=temp(index+1:end);

fwrite(object.VISA,'CALIBRATE:STATUS?');
temp=strtrim(fscanf(object.VISA));
format=repmat('%d,',[1 10]);
format=format(1:end-1);
temp=sscanf(temp,format);
value.Status.OscilliscopeFrame=temp(1);
value.Status.Channel1Vertical=temp(2);
value.Status.Channel1Trigger=temp(3);
value.Status.Channel2Vertical=temp(4);
value.Status.Channel2Trigger=temp(5);
value.Status.Channel3Vertical=temp(6);
value.Status.Channel3Trigger=temp(7);
value.Status.Channel4Vertical=temp(8);
value.Status.Channel4Trigger=temp(9);
value.Status.AuxTrigger=temp(1);

fwrite(object.VISA,'CALIBRATE:TEMP?');
temp=strtrim(fscanf(object.VISA));
index=strfind(temp,',');
value.Tshift.TimeScale=temp(1:index-1);
value.Tshift.Regular=temp(index+1:end);

end