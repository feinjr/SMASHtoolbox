function data=object2structure(object)

data=struct();
temp=metaclass(object);
name=temp.PropertyList;
for k=1:numel(name)
    try
        data.(name(k).Name)=object.(name(k).Name);
    catch
        % do nothing
    end
end

end