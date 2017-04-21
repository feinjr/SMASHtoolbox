function value=getAverage(object)

communicate(object);

fwrite(object.VISA,'ACQUIRE:AVERAGE?');
value=strtrim(fscanf(object.VISA));
value=sscanf(value,'%g');
if value==0
    return
end

fwrite(object.VISA,'ACQUIRE:AVERAGE:COUNT?');
value=strtrim(fscanf(object.VISA));
value=sscanf(value,'%g');
if value < 2
    value=0;
end


end