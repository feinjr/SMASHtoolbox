
function value=getAcquisition(object)

communicate(object);

%
fwrite(object.VISA,'ACQUIRE:SRATE:ANALOG?');
temp=strtrim(fscanf(object.VISA));
value.SampleRate=sscanf(temp,'%g');

%
fwrite(object.VISA,'ACQUIRE:POINTS:ANALOG?');
temp=strtrim(fscanf(object.VISA));
value.NumberPoints=sscanf(temp,'%g');

%
fwrite(object.VISA,'ACQUIRE:AVERAGE?');
temp=strtrim(fscanf(object.VISA));
temp=sscanf(temp,'%g');
if temp==0
    % do nothing
else
    fwrite(object.VISA,'ACQUIRE:AVERAGE:COUNT?');
    temp=strtrim(fscanf(object.VISA));
    temp=sscanf(temp,'%g');
    if temp < 2
        temp=0;
    end
end
value.NumberAverages=temp;

end