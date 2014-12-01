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

end