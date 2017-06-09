function lock(object)

% manage multiple digitizers
if numel(object) > 1
    for k=1:numel(object)
        lock(object(k));
    end
    return
end

% lock digitizer
communicate(object);

switch object.System.Class
    case 'Infiniium'
        fwrite(object.VISA,'SYSTEM:LOCK ON');
        fwrite(object.VISA,'SYSTEM:GUI OFF');
end

end