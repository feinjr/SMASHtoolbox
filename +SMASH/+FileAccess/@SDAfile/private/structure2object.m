function object=structure2object(data,ObjectClass)

try % pass structure to (static) restore method
    name=sprintf('%s.restore',ObjectClass);
    object=feval(name,data);
    return
catch 
    % proceed to next block
end

try % pass structure to constructor
    object=feval(ObjectClass,data);   
    return
catch
    % proceed to next block
end

try % manually transfer structure fields to property values
    object=feval(ObjectClass);
    name=fieldnames(data);
    for n=1:numel(name)
        if isprop(object,name{n})
            object.(name{n})=data.(name{k});
        end
    end
catch
    error('ERROR: unable to extract %s object',ObjectClass);
end

end