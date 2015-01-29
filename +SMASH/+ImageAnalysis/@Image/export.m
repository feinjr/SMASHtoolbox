% EXPORT Export object simple data file
%
% This method exports objects to a data file for use outside of the Image
% class.  Columns in this file are built from the the object's limited
% Grid/Data arrays and labeled accordingly.
% 
% Useage:
%   >> export(object,filename);
% Exporting to the following graphic file formats are supported:
% *.bmp,*.jpg, *.jpeg,*.png,*.tif,*.tiff
% 
% If the Image is to be exported to a Sandia Data Archive, 
% the file name must have the extension *.sda and a label must be given.
%    >> export(object,filename,label);
%
% See also IMAGE, store

% created October 7, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 18, 2013 by Tommy Ao (Sandia National Laboratories)
% modified January 27, 2015 by Daniel Dolan
%   -added PFF support
function export(object,filename,mode,label)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(ischar(filename),'ERROR: invalid file name');
assert(~isempty(filename),'ERROR: invalid file name');
[~,fname,extension]=fileparts(filename);
extension=lower(extension);

if (nargin<3) || isempty(mode)   
    mode='create';
end

if nargin<4
    label='';
end

% get data from object
x=object.Grid1;
y=object.Grid2;
z=object.Data;

% place data into file
switch extension
    case '.sda'
        if isempty(label)
            error('ERROR: label needed to place data into SDA');
        end
        %header=sprintf('%s %s %s',object.Grid1Label,object.Grid2Label,object.DataLabel);
        archive=SMASH.FileAccessSDA(filename,mode);
        archive.Precision='single';
        archive.Deflate=2;
        data.X=x;
        data.Y=y;
        data.Z=Z;
        insert(archive,label,data); % this may need some work
        describe(archive,label,header);
    case '.pff'
        data=struct();
        data.Grid={object.Grid1 object.Grid2};
        data.GridLabel={object.Grid1Label object.Grid2Label};
        data.Vector={object.Data};
        data.VectorLabel={object.DataLabel};
        data.Type='Image export';
        data.Title=object.Name;
        archive=SMASH.FileAccess.PFFfile(filename);
        write(archive,data,mode);
    case {'.bmp','.jpg','.jpeg','.png','.tif','.tiff'}
        xheader=sprintf('%s ',object.Grid1Label);        
        yheader=sprintf('%s ',object.Grid2Label);        
        xfilename=strcat(fname,'Grid1.txt');
        if exist(xfilename,'file')
            delete(xfilename);
        end
        SMASH.FileAccess.writeFile(xfilename,x,'%#+e\n',xheader);
        yfilename=strcat(fname,'Grid2.txt');
        if exist(yfilename)
            delete(yfilename);
        end
        SMASH.FileAccess.writeFile(yfilename,y,'%#+e\n',yheader);
        imwrite(z/max(z(:)),filename,imtype);
    otherwise
        error('ERROR: unsupported image export file type');
end

end