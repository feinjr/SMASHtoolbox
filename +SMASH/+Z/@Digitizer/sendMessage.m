function message(object,in)

% manage input
assert((nargin == 2) && ischar(in),'ERROR: invalid message');

communicate(object);
command=sprintf('SYSTEM:DSP "%s"',in);
fwrite(object.VISA,command);

end