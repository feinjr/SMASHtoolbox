% setupDiagnostic Set up diagnostic channels
%
% This method defines the available diagnostic channels in a PDV
% measurement.  Each channel is identified by a unique integer index.
%   setupDiagnostic(object,index);
% For example, the input [1 2] indicates that two channels, "1" and "2",
% are available.
%
% Each diagnostic channel is assigned an internal delay, which represents
% the optical/electrical transit from the PDV input to the digitizer input.
% The default delay for each channel is zero.  Custom values are specified
% as follows.
%   setupDiagnostic(object,index,delay);
% The numeric input "delay" must either be empty (indicating the default
% state) or have the same number of elements as "index".
%
% See also PDVtiming, characterizeDiagnostic
%

%
% created December 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function setupDiagnostic(object,index,delay)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

assert(isValidIndex(index),'ERROR: invalid diagnostic index value');
index=reshape(index,[1 numel(index)]);
temp=unique(index);
assert(numel(temp)==numel(index),'ERROR: repeated diagnostic index');

if (nargin<3) || isempty(delay)
    delay=zeros(size(index));
end
assert(isnumeric(delay),'ERROR: invalid diagnostic delay value');
delay=reshape(delay,[1 numel(delay)]);

% store values
object.Diagnostic=index;
N=numel(index);

assert(numel(delay)>=N,'ERROR: insufficient number of diagnostic delays');
object.DiagnosticDelay=delay;


end