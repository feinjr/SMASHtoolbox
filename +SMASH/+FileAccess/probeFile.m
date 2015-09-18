% PROBEFILE Reveal contents of a multi-record file
% 
% This function reveals the contents of multi-record files.  
%    >> probefile(filename,format);
% The following formats can be used specified when a file is probed.
%     -'agilent' and 'keysight'
%     -'zdas' and 'saturn'
%     -'pff' and 'sda'
%     -'column'
% The default format (if omitted or empty) is 'column'.
%
% When no output is specified (as above), file contents are printed in the
% command window.  This information can be captured as an output structure.
%    >> report=probeFile(...);
%
%
% See also FileAccess, SupportedFormats
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
assert(ischar(format),'ERROR: invalid format');

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
    case 'column'
        object=SMASH.FileAccess.ColumnFile(filename);
    otherwise
        error('ERROR: unable to probe ''%s'' format',format);
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
