% restore Restore object from an archive

function object=restore(data)

object=SMASH.Velocimetry.PDV([],1:10);
PropertyList=metaclass(object);
PropertyList=PropertyList.PropertyList;

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        dependent=false;
        for k=1:numel(PropertyList)
            if strcmp(PropertyList(k).Name,name{n}) && PropertyList(k).Dependent
                dependent=true;
                break
            end
        end
        if dependent
            continue
        end
        try
            object.(name{n})=data.(name{n});
        catch
            % do nothing
        end
    end
end

end