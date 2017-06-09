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

switch object.System.Class
    case 'Infiniium'
        fwrite(object.VISA,'SYSTEM:LOCK OFF');
        fwrite(object.VISA,'SYSTEM:GUI ON');
end

end