% This package manges access to text and binary files.  Supported text
% formats include:
%    'column'           : generic data organized in columns
%    'oceanoptics'      : Ocean Optics spectrometer measurements
%    'optronicslab'     : Optronics Laboratory spectrometer measurements
%    'optronicslabdump' : Optronic Laboratory spectrometer screen dumps
% Binary file support is provided for the following formats.
%    Digitizer signals: 'agilent','lecroy','tektronix','yokogawa'
%    Images           : 'film','graphics','optronis','plate','sbfp','winspec'
%    General purpose  : 'dig','pff','sda'
% Some groups manage a specific file type, while other groups (particularly
% 'film' and 'graphics') manage several related file types.  For more
% information, refer to the SMASH documentation.
%
% Functions provided in this toolbox are the easiest way to access files.
%    probeFile   - Reveal contents in a multi-record file (*.sda, *.pff, etc.)
%    readFile    - Read data from a file
%    mergeSplits - Merge split SDA files into a complete file
%    splitFile   - Split file across multiple SDA files
%    writeFile   - Write data to a file
%
% Classes are provided for more advanced file access.
% file formats.
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

% Last updated October 31, 2013