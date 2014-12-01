function insert_numeric(archive,setname,data,deflate)

% handle empty arrays
file=archive.ArchiveFile;
empty=false;
if isempty(data);
    empty=true;
    data=nan;
end

chunksize=size(data);
datatype=class(data);

% insert data
%datasize=size(data);
datasize=inf(1,ndims(data));
start=ones(1,ndims(data));
count=size(data);

h5create(file,setname,datasize,...
    'ChunkSize',chunksize,'Deflate',deflate,'DataType',datatype);
h5write(file,setname,data,start,count);
h5writeatt(file,setname,'RecordType','numeric');

if empty
    h5writeatt(file,setname,'Empty','yes');
else
    h5writeatt(file,setname,'Empty','no');
end