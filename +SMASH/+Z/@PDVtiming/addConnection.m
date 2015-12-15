% addConnection Add measurement connection
%
% This method defines a new connection for a PDV measurement.  Each
% measurement involves probe, diagnostic channel, digitizer, and
% digitizer channel indices.
%    addConnection(object,[probe diagnostic digitizer channel]);
% Each index must match previously defined system capabilities; invalid
% indices will generate an error message.  An optional measurement label
% can be associated with the connection.
%    addConnection(object,map,label); % map is a four-element array
% Measurement labels are *strongly* encouraged.
%
% Each measuremnt should have a unique probe and diagnostic index;
% digitizer indices can be repeated within the limites of the available
% channels.  Repeated indices are identified when new connections are
% added.  When this method is called as above (without an output), repeated
% index warnings are printed in the command window.  Repeat information can
% also be returned as a logical array, suppressing these warnings.
%    repeat=addConnection(...);
% The output "repeat" is a three-element logical array indicating repeated
% probe, diagnostic, and digitizer/channel index values (respectively).
%
% See also PDVtiming, checkConnection, removeConnection
%

%
% created December 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=addConnection(object,map,label)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(isnumeric(map),'ERROR: invalid connection map');

if (nargin<3) || isempty(label)
    label='New connection';
end
assert(ischar(label),'ERROR: invalid connection label');

% add connection and verify
checkConnection(object,map);
object.MeasurementConnection(end+1,:)=map;
object.MeasurementLabel{end+1}=label;

% manage output
if nargout==0
   checkConnection(object);        
else
    repeat=checkConnection(object);
    varargout{1}=repeat;
end

end