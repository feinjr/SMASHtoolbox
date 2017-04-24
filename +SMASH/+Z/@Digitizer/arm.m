function arm(object,mode)

% manage input
if (nargin < 2) || isempty(mode)
    mode='single';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);

%
communicate(object)
fwrite(object.VISA,':ADER?'); % clear Acquisition Done Event Register
clearScreen(object);
switch mode
    case 'single'
        fwrite(object.VISA,':single');
        object.State='single';
    case 'run'
        fwrite(object.VISA,':run');
        object.State='run';
    case 'stop'
        fwrite(object.VISA,':stop');
        object.State='stop';
    otherwise
        error('ERROR: invalid mode');
end

end