function lock(object,mode)

if (nargin < 2) || isempty(mode)
    mode='standard';
end
errmsg='ERROR: invalid lock mode';
assert(ischar(mode),errmsg);

communicate(object);
switch lower(mode)
    case 'standard'
        fwrite(object.VISA,'SYSTEM:LOCK ON');
        message(object,'Panel controls are locked');
    case 'gui'
        fwrite(object.VISA,'SYSTEM:GUI OFF');
    otherwise
        error(errmsg);
end

end