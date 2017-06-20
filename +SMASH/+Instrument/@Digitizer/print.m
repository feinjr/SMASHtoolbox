function print(object,fid)

% manage input
if (nargin < 2) || isempty(fid)
    fid=1;
end

% multiple digitizers
if numel(object > 1)
    for m=1:numel(object)
        print(object(m),dig);
    end
    return
end

% single digitizers
fprintf(fid,'Digitizer name : %s\n',dig.Name);

name={'System' 'Acquisition' 'Trigger'};
for k=1:numel(name)
    fprintf('%s settings:\n',name{k});
    temp=object.(name{k});
    local=fieldnames(temp);
    for m=1:numel(local)
        printSmart(local,temp.(local),fid);
    end
end

for k=1:4
    fprintf('Channel %d settings:\n',k);    
    temp=dig.Channel(k);
    local=fieldnames(temp);
    for m=1:numel(local)
        printSmart(local,temp.(local),fid);
    end
end

end

function printSmart(label,value,fid)

fprintf('\t%s : ',label);

if ischar(value)
    fprintf(fid,'%s',value);
elseif isnumeric(value) || islogical(value)
    fprintf(fid,'%g ',value);
else
    error('ERROR: invalid value type');
end

fprintf('\n');

end