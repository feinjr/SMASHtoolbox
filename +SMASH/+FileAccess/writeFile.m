% WRITEFILE Write data to a file
%
% This method writes data from MATLAB to a file in 'column', 'dig', or
% 'sda' format based on the specified file extension.  Any extension other
% than *.dig or *.sda uses the 'column' format, which requires a numerical
% "table" input.
%    >> writeFile('myfile.txt',table,[format],[header]); % 'column' format
% An optional format string can be passed to control how the data table is
% written ; MATLAB's "fprintf" documentation describes how format strings
% are constructed.  An optional cell array "header" can also be specified;
% each element of this array is printed as a line at the beginning of the
% file.
%
% The 'dig' format is used for *.dig files, which requires numerical arrays
% "time" and "signal" of the same size.
%    >> writeFile('myfile.dig',time,signal); % 'dig' format
%
% The 'sda' format is used for *.sda files, which require text inputs
% "category" and "label".
%    >> writeFile('myfile.sda',category,label,...); % 'sda' format
% Additional write inputs for SDA files depend on the category; refer to
% the format documentation for more information.
%
% See also FileAccess, fprintf, SDAfile
%

%
% created October 31, 2013 by Daniel Dolan (Sandia National Laboratories)
% updated April 11, 2014 by Daniel Dolan
%    -Revised documentation, adding links 
%
function writeFile(filename,varargin)

% handle file name
if (nargin<1) || isempty(filename)
    [filename,pathname]=uiputfile({'*.*','All files'},'Select file');
    if isnumeric(filename)
        error('ERROR: no file selected');
    end
    filename=fullfile(pathname,filename);
end

% write file
[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.dig'
        object=SMASH.FileAccess.DIGfile(filename);
        write(object,varargin{:});
    case '.sda'
        object=SMASH.FileAccess.SDAfile(filename);
        insert(object,varargin{:});
    otherwise
        object=SMASH.FileAccess.ColumnFile(filename);
        write(object,varargin{:});
end

end