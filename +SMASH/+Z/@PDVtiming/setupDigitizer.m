% setupDigitizer Set up digitizers
%
% This method defines the available digitizers in a PDV measurement.  Each
% digitizer is identified by a unique integer index.
%   setupDigitizer(object,index);
% For example, the input [1 2] indicates that two digitizers, "1" and "2",
% are available.
%
% Each digitizer is assigned an output trigger delay and output trigger
% time (on a master time base).  The default values are zero for each
% digitizer.  Custom values are specfified as follows.
%   setupDigitizer(object,index,delay,trigger);
% Inputs "delay" and "trigger" must be numeric arrays.  Empty arrays
% indicate the default value; otherwise, the number of elements must match
% the "index array.
%
% See also PDVtimging, characterizeDigitizer, characterizeTrigger
%

%
% created December 12, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function setupDigitizer(object,index,delay,trigger)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

assert(isValidIndex(index),'ERROR: invalid digitizer index value');
index=reshape(index,[1 numel(index)]);
temp=unique(index);
assert(numel(temp)==numel(index),'ERROR: repeated digitizer index');

if (nargin<3) || isempty(delay)
    delay=zeros(size(index));
end
assert(isnumeric(delay),'ERROR: invalid digitizer delay value');
delay=reshape(delay,[1 numel(delay)]);

if (nargin<4) || isempty(trigger)
    trigger=zeros(size(index));
end
assert(isnumeric(trigger),'ERROR: invalid trigger value')
trigger=reshape(trigger,[1 numel(trigger)]);

% store values
object.Digitizer=index;
N=numel(index);

assert(numel(delay)>=N,'ERROR: insufficient number of delays');
object.DigitizerDelay=delay;

assert(numel(trigger)>=N,'ERROR: insufficient number of delays');
object.DigitizerTrigger=trigger;

end