%
% list=scan('*');
% list=scan('0-10');
% 
% list=scan('*.*');

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
delay=SMASH.System.ping(list,timeout);
list=list(~isnan(delay));

SMASH.Z.Digitizer.reset();
keep=false(size(list));
for k=1:numel(list)
    try
        [~]=SMASH.Z.Digitizer(list{k});
        keep(k)=true;
    catch
        continue
    end    
end
list=list(keep);

SMASH.Z.Digitizer.reset();

end