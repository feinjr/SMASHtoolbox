% restore Restore object from an archive

function object=restore(data)

object=SMASH.Nuclear.NTOF([],NaN);

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        try
            object.(name{n})=data.(name{n});
        catch
            % do nothing
        end
    end
end

end