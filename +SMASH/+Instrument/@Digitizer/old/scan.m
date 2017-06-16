% scan Scan for active IP addresses
%
% This method scans for active IP addresses.  Addresses can be specified
% explicitly:
%    list=scan('192.168.0.100');
% or with respect to the local host.
%    list=scan('*');
%    list=scan('0-10');
% The output "list" is a cell array of active IP4 addresses.
% 
% See also Digitizer
%

%
% created May 23, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function list=scan(request,timeout)

% manage input
if ischar(request)
    try
        list=SMASH.System.listIP4(request);
    catch
        error('ERROR: invalid IP request');
    end
elseif iscellstr(request)
    list={};
    for n=1:numel(request)
        temp=SMASH.Z.Digitizer.scan(request{n});
        list=[list; temp]; %#ok<AGROW>
    end
    return
else
    error('ERROR: invalid IP request');
end

if (nargin < 2) || isempty(timeout)
    timeout=200; % ms
end
assert(isnumeric(timeout) && isscalar(timeout),...
    'ERROR: invalid time out value');

% look for digitizers
delay=SMASH.System.ping(list,timeout,'silent');
list=list(~isnan(delay));

end