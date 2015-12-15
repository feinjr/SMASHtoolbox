% removeConnection Remove measurement connection
%
% This method removes connections from a PDV measurement.  Connections are
% removed by numeric index:
%    removeConnection(object,index);
% Single more multiple index values may be specified.  To remove all
% connections:
%    removeConnections(object,'all');
%
% See also PDVtiming, addConnection, checkConnection
%

%
% created December 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function removeConnection(object,index)

N=numel(object.MeasurementLabel);

% manage input
if (nargin<2) || isempty(index)
    index=N;
end
if strcmpi(index,'all');
    index=1:N;    
end
assert(isnumeric(index),'ERROR: invalid connection index');

% remove connection
valid=1:N;
keep=true(N,1);
for k=index
   assert(any(k==valid),'ERROR: invalid connection index');
   keep(k)=false;
end

object.MeasurementConnection=object.MeasurementConnection(keep,:);
object.MeasurementLabel=object.MeasurementLabel(keep);

end