% EXPORT Export object to a basic data file
%
% This method exports a Signal object to a basic data file, recording only
% the Grid/Data arrays in the limited region.
%    >> export(object,filename); % typical file extensions: *.txt, *.dat, *.out, ...
% By default, Signal objects are exported to a text file using the 'column'
% format.  If the export file has the extension *.sda, the object is
% exported to a record inside a Sandia Data Archive and a label is
% required.
%    >> export(object,filename,label); % *.sda file extension
% Signal objects can also be exported to PFF files.
%    >> export(object,filename); % %
%
% See also Signal, store
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories) 
% revised January January 27, 2015 by Daniel Dolan
%   -added PFF support
function export(object,filename,mode,label)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(ischar(filename),'ERROR: invalid file name');
assert(~isempty(filename),'ERROR: invalid file name');
[~,~,extension]=fileparts(filename);
extension=lower(extension);

if (nargin<3) || isempty(mode)   
    mode='create';
end

if nargin<4
    label='';
end

% place data into file
[x,y]=limit(object);
if strcmp(extension,'.sda')
    if isempty(label)
        error('ERROR: label needed to place data into SDA');
    end    
    archive=SMASH.FileAccess.SDAfile(filename,mode);
    archive.Precision=object.Precision;
    archive.Deflate=2;
    data=struct();
    data.X=x;
    data.Y=y;
    insert(archive,label,data); % this may need work!
    describe(archive,label,object.Name);
elseif strcmp(extension,'.pff')
    data=struct();
    data.Grid={object.Grid};
    data.GridLabel={object.GridLabel};
    data.Vector={object.Data};
    data.VectorLabel={object.DataLabel};   
    data.Type='Signal export';
    data.Title=object.Name;
    archive=SMASH.FileAccess.PFFfile(filename);
    write(archive,data,mode);
else
    data=[x(:) y(:)];  
    header=sprintf('%s %s',object.GridLabel,object.DataLabel);
    SMASH.FileAccess.writeFile(filename,data,'%#+e\t%#+e\n',header);
end

end