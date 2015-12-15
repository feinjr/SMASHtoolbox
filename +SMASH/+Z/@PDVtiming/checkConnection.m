% checkConnection Check measurement connections
%
% This method checks connections in a PDV measurement.  
%    checkConnection(object);
% Invalid index values generate an error, while repeated index values
% generate a warning.  Specifying an output:
%    repeat=checkConnection(object);
% suppresses warnings and returns a logical array indicating repeated
% probe, diagnostic, and digitizer/channel index values (respectively).
%
% See also PDVtiming, addConnection, removeConnection
%

%
% created December 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=checkConnection(object,map)

% manage input
if (nargin<2) || isempty(map)
    map=object.MeasurementConnection; 
else
    % This mode intended for internal use only
end

% error testing
N=size(map,1);
for n=1:N
    assert(any(map(n,1)==object.Probe),'ERROR: invalid probe index');
    assert(any(map(n,2)==object.Diagnostic),...
        'ERROR: invalid diagnostic index');
    assert(any(map(n,3)==object.Digitizer),...
        'ERROR: invalid digitizer index');
    assert(any(map(n,4)==object.DigitizerChannel{map(n,3)}),...
        'ERROR: invalid digitizer channel');
end

% repeat testing
repeat=zeros(1,3); % [probe diagnostic digitizer/channel]
for n=2:N
    kn=1:(n-1);
    if any(map(n,1)==map(kn,1))
        repeat(1)=repeat(1)+1;
    end
    if any(map(n,2)==map(kn,2))
        repeat(2)=repeat(2)+1;
    end
    if any(map(n,3)==map(kn,3) & map(n,4)==map(kn,4))
        repeat(3)=repeat(3)+1;
    end   
end
repeat=logical(repeat);

% manage output
if nargout==0
    if repeat(1)
        warning('SMASH:PDVtiming','Repeated probe index');
    end
    if repeat(2)
        warning('SMASH:PDVtiming','Repeated diagnostic index');
    end
    if repeat(3)
        warning('SMASH:PDVtiming','Repeated digitizer/channel index');
    end
else
    varargout{1}=repeat;
end

end