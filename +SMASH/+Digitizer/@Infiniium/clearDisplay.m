function clearDisplay(object)

% manage multiple digitizers
if numel(object) > 1
    for k=1:numel(object);
        clearDisplay(object(k));
    end
    return
end

% send command
fwrite(object.VISA,'CDISPLAY')

end