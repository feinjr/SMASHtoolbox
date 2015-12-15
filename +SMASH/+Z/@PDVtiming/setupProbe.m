% setupProbe Set up probes
%
% This method defines the probes used in a PDV measurement.  Each probe is
% identified with a unique integer index.
%    setupProbe(object,index);
% For example, the index [1 2] indicates that two probes, "1" and "2",
% are available.
%
% Each probe is assigned an opical delay, the one-way transit time from the
% probe to the PDV input.  The default delay for each probe is zero.
% Custom values are specified as follows.
%   setupProbe(object,index,delay);
% The numeric input "delay" must either be empty (indicating the default
% state) or have the same number of elements as "index".
%
% See also PDVtiming, characterizeProbe
% 

%
% created December 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function setupProbe(object,index,delay)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

assert(isValidIndex(index),'ERROR: invalid probe index value');
index=reshape(index,[1 numel(index)]);
temp=unique(index);
assert(numel(temp)==numel(index),'ERROR: repeated probe index');

if (nargin<3) || isempty(delay)
    delay=zeros(size(index));
end
assert(isnumeric(delay),'ERROR: invalid probe delay value');
delay=reshape(delay,[1 numel(delay)]);

% store values
object.Probe=index;
N=numel(index);

assert(numel(delay)>=N,'ERROR: insufficient number of probe delays');
object.ProbeDelay=delay;

end