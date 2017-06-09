function value=getCalibration(object)

communicate(object);

value='';
switch object.System.Class
    case 'Infiniium'        
        fwrite(object.VISA,'CALIBRATE:DATE?');        
        temp=strtrim(fscanf(object.VISA));
        index=strfind(temp,',');
        dateA=temp(1:index-1);
        dateB=temp(index+1:end);
        fwrite(object.VISA,'CALIBRATE:STATUS?');
        flags=strtrim(fscanf(object.VISA));
        fwrite(object.VISA,'CALIBRATE:TEMP?');
        temp=strtrim(fscanf(object.VISA));
        index=strfind(temp,',');
        tA=temp(1:index-1);
        tB=temp(index+1:end);
        %             
        value{end+1}=sprintf('Time scale calibration: %s (%+g C)',dateA,sscanf(tA,'%g'));
        %value{end+1}=sprintf('\t Temperature shift : %s',tA);
        value{end+1}=sprintf('General calibration performed %s (%+g C)',dateB,sscanf(tB,'%g'));
        %value{end+1}=sprintf('\t Temperature shift : %s',tB);
        value{end+1}=sprintf('Status flags: %s',flags);
    case 'InfiniiScope'
        % under construction
end

value=value(:);

end