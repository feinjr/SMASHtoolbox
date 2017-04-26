function lock(object,mode)

% manage input
if (nargin < 2) || isempty(mode)
    mode='standard';
end
errmsg='ERROR: invalid lock mode';
assert(ischar(mode),errmsg);

% manage multiple digitizers
if numel(object) > 1
    for k=1:numel(object)
        lock(object(k),mode);
    end
    return
end

% lock digitizer
communicate(object);
switch lower(mode)
    case 'standard'
        fwrite(object.VISA,'SYSTEM:LOCK ON');
        sendMessage(object,'Panel controls are locked');
    case 'gui'
        fwrite(object.VISA,'SYSTEM:GUI OFF');
    otherwise
        error(errmsg);
end

end