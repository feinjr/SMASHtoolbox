function print(object,fid)

% manage input
if (nargin < 2) || isempty(fid)
    fid=1;
end

% multiple digitizers
if numel(object) > 1
    for m=1:numel(object)
        print(object(m),fid);
    end
    return
end

% single digitizers
fprintf(fid,'\nDigitizer name : %s\n',object.Name);

name={'System' 'Acquisition' 'Trigger'};
for k=1:numel(name)
    fprintf(fid,'%s settings:\n',name{k});
    temp=object.(name{k});
    local=fieldnames(temp);
    for m=1:numel(local)
        printSmart(local{m},temp.(local{m}),fid);
    end
end

for k=1:4
    fprintf(fid,'Channel %d settings:\n',k);    
    temp=object.Channel(k);
    local=fieldnames(temp);
    for m=1:numel(local)
        printSmart(local{m},temp.(local{m}),fid);
    end
end

end

function printSmart(label,value,fid)

fprintf(fid,'\t%s : ',label);

if ischar(value)
    fprintf(fid,'%s',value);
elseif isnumeric(value) || islogical(value)
    fprintf(fid,'%g ',value);
else
    error('ERROR: invalid value type');
end

fprintf(fid,'\n');

end