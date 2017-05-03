function unlock(object,mode)

if (nargin < 2) || isempty(mode)
    mode='both';
end

% manage multiple digitizers
if numel(object) > 1
    for k=1:numel(object)
        unlock(object(k));
    end
    return
end

% unlock digitizer
communicate(object);
switch mode
    case 'standard'
        fwrite(object.VISA,'SYSTEM:LOCK OFF');
    case 'gui'
        fwrite(object.VISA,'SYSTEM:GUI ON');
    otherwise
        fwrite(object.VISA,'SYSTEM:LOCK OFF');
        fwrite(object.VISA,'SYSTEM:GUI ON');
end
sendMessage(object,'');

end