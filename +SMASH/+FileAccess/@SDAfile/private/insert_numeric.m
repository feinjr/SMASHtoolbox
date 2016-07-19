function insert_numeric(archive,setname,data,deflate)

% handle empty arrays
file=archive.ArchiveFile;
empty=false;
if isempty(data);
    empty=true;
    data=nan;
end

% manage sparse arrays
if issparse(data)
    [i,j,s]=find(data);
    data=[i(:) j(:) s(:)];
    insert_numeric(archive,setname,data,deflate);
    h5writeatt(file,setname,'Sparse','yes');
    return
end

% insert data
chunksize=size(data);
datatype=class(data);

datasize=inf(1,ndims(data));
start=ones(1,ndims(data));
count=size(data);

h5create(file,setname,datasize,...
    'ChunkSize',chunksize,'Deflate',deflate,'DataType',datatype);
h5write(file,setname,data,start,count);
h5writeatt(file,setname,'RecordType','numeric');
h5writeatt(file,setname,'Sparse','no');

if empty
    h5writeatt(file,setname,'Empty','yes');
else
    h5writeatt(file,setname,'Empty','no');
end