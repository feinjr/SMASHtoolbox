function arm(object,mode)

% manage input
if (nargin < 2) || isempty(mode)
    mode='single';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);

%
communicate(object)
%clearScreen(object);
switch mode
    case 'single'
        fwrite(object.VISA,':single');
    case 'run'
        fwrite(object.VISA,':run');
    case 'stop'
        fwrite(object.VISA,':stop');
    otherwise
        error('ERROR: invalid mode');
end

end