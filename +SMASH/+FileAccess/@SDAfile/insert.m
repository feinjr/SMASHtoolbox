% insert Insert data into an archive
%
% This method inserts a data contained in a MATLAB variable into an archive
% file.  The variable is stored with a unique text label for identification
% and access.  The following variable types are supported.
%    -numeric arrays (double, single, uint8, ...)
%    -logical arrays
%    -character arrays
%    -structure arrays
%    -cell arrays
%    -objects (*not* object arrays)
% Arbitrary array sizes and dimensionality are permitted for each variable
% type; sparse arrays are automatically conveted to double precision.
% Nested variables--structures within structures, cell arrays within cell
% arrays, cell arrays within structures, etc.--are also allowed.
%
% The basic call for this method is:
%    >> insert(archive,label,data,[description],[deflate]);
% where the second and third inputs are mandatory.  An optional text
% description can be specified as the fourth input.  The (optional) fifth
% input specifies the deflate parameter (integer from 0 to 9), which
% controls the compression level.
%
% See also SDAfile, extract, import, probe

%
% created October 9, 2014 by Daniel Dolan (Sandia National Labs)
%    -revised to match new SDA specification
% revised March 10, 2016 by Daniel Dolan
%    -added supported for structure arrays.
function insert(archive,label,data,description,deflate)

% handle input
assert(nargin>=3,'ERROR: invalid number of inputs');

if (nargin<4) || isempty(description)
    description='';
end

if (nargin<5) || isempty(deflate)
    deflate=0;
end

% see if archive file is writable
setting = h5readatt(archive.ArchiveFile,'/','Writable');
if strcmpi(setting,'no')
    fprintf('Data not inserted because archive is not writable\n');
    return
end

% verify label
if any(label=='/') || any(label=='\')
    error('ERROR: invalid label');
end

datasetname=['/' label];
try
    h5readatt(archive.ArchiveFile,datasetname,'RecordType');
    taken=true;
catch
    taken=false;
end
assert(~taken,'ERROR: label already taken');

% insert data based on type
if isnumeric(data)
    subname=repmat(datasetname,[1 2]);
    insert_numeric(archive,subname,data,deflate);
    h5writeatt(archive.ArchiveFile,datasetname,'RecordType','numeric');
    h5writeatt(archive.ArchiveFile,datasetname,'Empty',...
        h5readatt(archive.ArchiveFile,subname,'Empty'));
elseif islogical(data)
    subname=repmat(datasetname,[1 2]);
    insert_logical(archive,subname,data,deflate);
    h5writeatt(archive.ArchiveFile,datasetname,'RecordType','logical');
    h5writeatt(archive.ArchiveFile,datasetname,'Empty',...
        h5readatt(archive.ArchiveFile,subname,'Empty'));
elseif ischar(data)
    subname=repmat(datasetname,[1 2]);
    insert_character(archive,subname,data,deflate);
    h5writeatt(archive.ArchiveFile,datasetname,'RecordType','character');
    h5writeatt(archive.ArchiveFile,datasetname,'Empty',...
        h5readatt(archive.ArchiveFile,subname,'Empty'));
elseif isa(data,'function_handle')
    insert_function(archive,repmat(datasetname,[1 2]),data,deflate);
    h5writeatt(archive.ArchiveFile,datasetname,'RecordType','function');
        h5writeatt(archive.ArchiveFile,datasetname,'Empty','false');
elseif isstruct(data)
    if isscalar(data)
        insert_structure(archive,datasetname,data,deflate);
    else
        temp=cell(size(data));
        for n=1:numel(data)
            temp{n}=data(n);
        end
        insert_cell(archive,datasetname,temp,deflate);
        h5writeatt(archive.ArchiveFile,['/' label],...
            'RecordType','structures');       
    end   
elseif iscell(data)
    insert_cell(archive,datasetname,data,deflate);
elseif isobject(data) % convert objects to structures
    errmsg{1}    ='ERROR: object arrays are not supported:';
    errmsg{end+1}='Suggestions:';
    errmsg{end+1}='   -Convert to a cell array of individual objects';
    errmsg{end+1}='   -Store individual objects as separate records';
    assert(numel(data)==1,'%s\n',errmsg{:});
    ObjectClass=class(data);
    data=object2structure(data);
    insert_structure(archive,datasetname,data,deflate);
    h5writeatt(archive.ArchiveFile,['/' label],'RecordType','object');
    h5writeatt(archive.ArchiveFile,['/' label],'ClassName',ObjectClass);
end
h5writeatt(archive.ArchiveFile,datasetname,'Description',description);
h5writeatt(archive.ArchiveFile,datasetname,'Deflate',deflate);

h5writeatt(archive.ArchiveFile,'/','Updated',datestr(now));

end