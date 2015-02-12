function object=structure2object(data,ClassName)

try % pass structure to (static) restore method
    name=sprintf('%s.restore',ClassName);
    object=feval(name,data);
    %return
catch
    message={};
    message{end+1}=sprintf(...
        'ERROR: unable to convert stored structure to an object');
    message{end+1}=sprintf(...
        '       The %s class does not provide a "restore" method',...
        ClassName);     
    warning('SDA:restore','%s\n',message{:});
    object=data;
end

end