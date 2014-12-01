function object=restore(object,data)

% transfer structure into array
%[~,name,ext]=fileparts(filename);
%data.Source=[name ext];
%data.SourceRecord=label;
%object=revealProperty(object,'SourceFormat','SourceRecord');

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        object.(name{n})=data.(name{n});
    end
end

end