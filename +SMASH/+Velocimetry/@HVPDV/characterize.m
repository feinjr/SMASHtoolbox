%

function [object,shape]=characterize(object,pulse)

% manage input
if (nargin<2) || isempty(pulse) || strcmpi(pulse,'all')
    pulse=1:object.NumberPulses;
end
assert(isnumeric(pulse),'ERROR: invalid pulse request');

% determine average pulse shape
shape=extract(object,pulse(1));
for n=2:numel(pulse)
    temp=extract(object,pulse(n));
    shape=shape+lookup(temp,shape.Grid,'extrap');
end
shape=shape/numel(pulse);

object.PulseShape=shape;

end