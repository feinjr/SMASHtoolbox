function object=structure2object(data,ObjectClass)

try % pass structure to constructor
    [object,success]=feval(ObjectClass,data);
    assert(success);
    return
catch
    % do nothing
end

try % manual transfer
    object=feval(ObjectClass);
    name=fieldnames(data);
    for n=1:numel(name)
        if isprop(object,name{n})
            object.(name{n})=data.(name{k});
        end
    end
catch
    error('ERROR: unable to extract %s object',metadata.Class);
end

end