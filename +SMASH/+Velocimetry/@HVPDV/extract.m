%

function [local,tc]=extract(object,pulse)

% manage input
if (nargin<2) || isempty(pulse)
    pulse=1;
end
valid=1:object.NumberPulses;
assert(isnumeric(pulse) && isscalar(pulse) && any(pulse==valid),...
    'ERROR: invalid pulse requested');

% extract requested pulse
bound=object.PulseBound(pulse,:);
local=crop(object.Measurement,bound);
tc=object.PulseCenter(pulse);
local=shift(local,-tc);

end