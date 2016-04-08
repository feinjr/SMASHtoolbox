function insert_structure(archive,setname,data,deflate)

file=archive.ArchiveFile;

for m=1:numel(data)
    name=fieldnames(data(m));
    for k=1:numel(name)
        value=data(m).(name{k});
        local=[setname '/' name{k}];
        if isnumeric(value)
            insert_numeric(archive,local,value,deflate);
        elseif islogical(value)
            insert_logical(archive,local,value,deflate);
        elseif ischar(value)
            insert_character(archive,local,value,deflate);
        elseif isa(value,'function_handle')
            insert_function(archive,local,value,deflate);
        elseif isstruct(value)
            insert_structure(archive,local,value,deflate);
        elseif iscell(value)
            insert_cell(archive,local,value,deflate);
        elseif isobject(value)
            insert_object(archive,local,value,deflate);           
        end
    end
    if isscalar(data)
        h5writeatt(file,setname,'RecordType','structure');
    else
        h5writeatt(file,setname,'RecordType','structures');
    end
    %h5writeatt(file,setname,'RecordSize',size(data));
    h5writeatt(file,setname,'Empty','no');    
    h5writeatt(file,setname,'FieldNames',sprintf('%s ',name{:}));    
end

end