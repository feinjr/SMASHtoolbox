function local=extract(object,pulse)

% manage input
if (nargin<2) || isempty(pulse)
    pulse=1;
end
valid=1:object.NumberPulses;
assert(isnumeric(pulse) && any(pulse==valid),...
    'ERROR: invalid pulse requested');

% extract requested pulse
bound=object.PulseBound(pulse,:);
local=crop(object.Measurement,bound);


end