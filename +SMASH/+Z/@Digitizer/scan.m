%
% object=scan('*');
% object=scan('0-10');
% 
% object=scan('*.*');

function object=scan(request)

% manage input
if ischar(request)
    try
        list=SMASH.System.listIP4(request);
    catch
        error('ERROR: invalid IP request');
    end
elseif iscellstr(request)
    object={};
    for n=1:numel(request)
        temp=SMASH.Z.Digitizer.scan(request{n});
        object=[object temp(:)]; %#ok<AGROW>
    end
    return
else
    error('ERROR: invalid IP request');
end

% look for digitizers
delay=SMASH.System.ping(list);
list=list(~isnan(delay));

object=[];
for k=1:numel(list)
    try
        temp=SMASH.Z.Digitizer(list{k});
    catch
        continue
    end
    if isempty(object)
        object=temp;
    else
        object(end+1)=temp; %#ok<AGROW>
    end
end

end