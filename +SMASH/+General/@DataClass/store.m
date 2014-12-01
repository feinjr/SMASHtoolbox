% store Store DataClass object
%

function store(object,filename,label,description,deflate)

% handle input
assert(nargin>=3,'ERROR: file name and archive label are required')

if (nargin<4) || isempty(description)
    description='';
end

if (nargin<5) || isempty(deflate)
    deflate=1;
end

archive=SMASH.FileAccess.SDAfile(filename);
insert(archive,label,object,description,deflate);
h5writeatt(filename,['/' label],'Class',class(object));
h5writeatt(filename,['/' label],'RecordType','object');

end