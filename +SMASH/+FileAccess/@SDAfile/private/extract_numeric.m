function data=extract_numeric(archive,setname)

file=archive.ArchiveFile;
empty=h5readatt(file,setname,'Empty');
if strcmp(empty,'yes')
    empty=true;
else
    empty=false;
end

if empty
    data=[];
else
    data=h5read(file,setname);
end

value=h5readatt(file,setname,'Sparse');
if strcmpi(value,'yes')
    data=sparse(data(:,1),data(:,2),data(:,3));
end

end