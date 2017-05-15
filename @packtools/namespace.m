% static method

function result=namespace(request)

errmsg='ERROR: invalid package request';
index=strfind(request,'.');
assert(~isempty(index),errmsg);
package=request(1:index(end)-1);
request=request(index(end)+1:end);

try
    object=meta.package.fromName(package);
catch
    error(errmsg);
end

result=struct();
expression=regexptranslate('wildcard',request);
for n=1:numel(object.ClassList)
    temp=object.ClassList(n).Name;
    if isempty(regexp(temp,expression))
        continue
    end
    field=temp;
    target=sprintf('%s.%s',package,temp);
    result.(field)=str2func(target);   
end

for n=1:numel(object.FunctionList)
    temp=object.FunctionList(n).Name;
    if isempty(regexp(temp,expression))
        continue
    end
    field=temp;
    target=sprintf('%s.%s',package,temp);
    result.(field)=str2func(target);
end

end