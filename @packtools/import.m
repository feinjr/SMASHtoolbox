% import Import package into a name space
%
% ns=packtools.import(name);
%
% The input can be an absolute package name, with or without wild cards
%    ns=packtools.import('Main.Sub.Function');
%    ns=packtools.import('Main.Sub.*');
%
% Relative naming within a package is also permitted.
%    ns=packtools.import('.Function');
%    ns=packtools.import('.*');
%    ns=packtools.import('.Sub.*');
%    ns=packtools.import('-.*');

%
function result=import(name)

% manage input
assert((nargin==1) && ischar(name) && ~isempty(name),...
    'ERROR: invalid input');
errmsg='ERROR: invalid name requested';

% relative name
if strcmp(name(1),'.') || strcmp(name(1),'-')
    [st,index]=dbstack('-completenames');
    assert(numel(st) > 1,...
        'ERROR: this method must be called from inside a package');
    if index ~= 1
        st=st(end:-1:1);
    end
    package=file2package(st(2).file);
    while numel(name) > 0
        index=strfind(package,'.');
        if name(1) == '-'
            assert(numel(index) > 0,errmsg);
            stop=index(end);
            package=package(1:stop-1);
            name=name(3:end);       
            continue
        elseif name(1) == '.'
            name=sprintf('%s.%s',package,name(2:end));
        else            
            name=sprintf('%s.%s',package,name);
        end
        break
    end  
    result=packtools.import(name);
    return
end   

% absolute name
index=strfind(name,'.');
assert(~isempty(index),errmsg);
package=name(1:index(end)-1);
name=name(index(end)+1:end);

try
    object=meta.package.fromName(package);
    assert(~isempty(object));
catch
    error(errmsg);
end

result=struct();
expression=regexptranslate('wildcard',name);
for n=1:numel(object.ClassList)
    temp=object.ClassList(n).Name;
    if isempty(regexp(temp,expression, 'once'))
        continue
    end
    field=temp;
    target=sprintf('%s.%s',package,temp);
    result.(field)=str2func(target);
end

for n=1:numel(object.FunctionList)
    temp=object.FunctionList(n).Name;
    if isempty(regexp(temp,expression, 'once'))
        continue
    end
    field=temp;
    target=sprintf('%s.%s',package,temp);
    result.(field)=str2func(target);
end
    
end