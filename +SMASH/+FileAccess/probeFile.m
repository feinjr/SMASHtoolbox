% PROBEFILE Reveal contents of a multi-record file
% 
% This function reveals the contents of multi-record files.  
%    >> probefile(filename);
% Supported file formats include *.sda (Sandia Data Archive), *.pff
% (Portable File Format), and *.h5 (Agilent digitizer files).  All other
% extensions are interpreted as text files in the "column" format.
%
% See also FileAccess
%

%
% created December 4, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function probeFile(filename,format)

% handle file name
if (nargin<1) || isempty(filename)
    [filename,pathname]=uigetfile({'*.*','All files'},'Select file');
    if isnumeric(filename)
        error('ERROR: no file selected');
    end
    filename=fullfile(pathname,filename);
end
assert(exist(filename,'file')==2,'ERROR: file not found');

if nargin<2
    format='';
end

% probe object
[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.h5'
        object=SMASH.FileAccess.DigitizerFile(filename,'agilent');   
    case '.hdf'
        switch lower(format)
            case {'zdas','saturn'}
                object=SMASH.FileAccess.DigitizerFile(filename,format);   
            otherwise
                error('ERROR: no format specified');
        end        
    case '.pff'
        object=SMASH.FileAccess.PFFfile(filename);
    case '.sda'
        object=SMASH.FileAccess.SDAfile(filename);   
    otherwise
        object=SMASH.FileAccess.ColumnFile(filename);
end

try
    probe(object)
catch
    error('ERROR: unable to probe file');
end

end
