function unlock(object)

% manage multiple digitizers
if numel(object) > 1
    for k=1:numel(object)
        unlock(object(k));
    end
    return
end

% unlock digitizer
communicate(object);
fwrite(object.VISA,'SYSTEM:LOCK OFF');
fwrite(object.VISA,'SYSTEM:GUI ON');
sendMessage(object,'');

end