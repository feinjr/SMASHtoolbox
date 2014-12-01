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
%
% See also Signal, store
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function export(object,filename,label)

% handle input
if nargin<2
    filename='';
end

if nargin<3
    label='';
end

% get data from object
[x,y]=limit(object);
header=sprintf('%s %s',object.GridLabel,object.DataLabel);

% place data into file
[~,~,ext]=fileparts(filename);
if strcmpi(ext,'.sda')
    if isempty(label)
        error('ERROR: label needed to place data into SDA');
    end
    archive=SMASH.FileAccess.SDAfile(filename);
    archive.Precision=object.Precision;
    archive.Deflate=9;
    insert(archive,'array1D',label,x,y);
    comment(archive,label,header);
else
    data=[x(:) y(:)];  
    SMASH.FileAccess.writeFile(filename,data,'%#+e\t%#+e\n',header);
end

end