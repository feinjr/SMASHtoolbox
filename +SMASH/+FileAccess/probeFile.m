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
function varargout=probeFile(filename,format,varargin)

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
    format=determineFormat(filename);
end

% probe object
switch format
    case {'agilent','keysight'}
        object=SMASH.FileAccess.DigitizerFile(filename,format);   
    case {'zdas','saturn'}
        object=SMASH.FileAccess.DigitizerFile(filename,format);    
    case 'pff'
        object=SMASH.FileAccess.PFFfile(filename);
    case 'sda'
        object=SMASH.FileAccess.SDAfile(filename);   
    otherwise
        object=SMASH.FileAccess.ColumnFile(filename);
end

try
    if nargout==0
        probe(object,varargin{:});
    else
        varargout=cell(1,nargout);
        [varargout{:}]=probe(object,varargin{:});
    end
catch
    error('ERROR: unable to probe file');
end



end
