function clearStatus(object)

% manage multiple digitizers
if numel(object) > 1
    for k=1:numel(object);
        clearStatus(object(k));
    end
    return
end

% send command
fwrite(object.VISA,'*CLS')

end