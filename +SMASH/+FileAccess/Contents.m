% This package manages access to text and binary files.  The function:
%    SupportedFormats - lists all supported file formats
%
% Functions provided in this toolbox are the easiest way to access files.
%    probeFile   - Reveal contents in a multi-record file (*.sda, *.pff, etc.)
%    readFile    - Read data from a file
%    writeFile   - Write data to a file
%
%    mergeSplits - Merge split SDA files into a complete file
%    splitFile   - Split file across multiple SDA files
%
%
% Classes provide more advanced file access.
%    ColumnFile    - text files containing columns
%    CustomFile    - custom text files
%    DIGfile       - Nevada Test Site DIG files
%    DigitizerFile - digitizer bindary files
%    ImageFile     - CCD, film, image plate, and standard graphic files
%    PFFfile       - Sandia Portable File Format files
%    SDAfile       - Sandia Data Archive files
%
% See also SMASH
%

% Last updated December 5, 2014