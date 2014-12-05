% SMASH supports many file formats.  Some of these formats are associated
% with a specific file type and extension, while others cover mutiple file
% types and/or extensions.  Specific associations, where they exist, are
% noted below.
%
% Text formats:
% 'column'           : Data stored in columns with an optional header
% 'oceanoptics'      : Ocean Optics spectrometer measurements
% 'optronicslab'     : OL-750 spectrometer measurments
% 'optronicslabdump' : OL-750 spectrometer screen dump
%
% Signal formats:
%   'agilent'        : Agilent digitizer files (*.h5)
%   'dig'            : Nevada Test Site signal files (*.dig)
%   'keysight'       : Keysight digitizer files (*.h5)
%   'lecroy'         : Lecroy digitizer files (*.trc)
%   'saturn'         : Saturn Data Acquisition System files (*.hdf)
%   'tektronix'      : Tektronix digitizer files (*.isf, *.wfm)
%   'yokogawa'       : Yokogawa digitizer files (*.wfm)
%   'zdas'           : Z Data Acquisition System files (*.hdf)
%
% Image formats:
%   'film'           : Microdensitometer file scans (*.img, *.hdf, *.pff)
%   'graphics'       : Standard graphic format (*.jpg, *.tif, etc.)
%   'hamamatsu'      : Hamamatsu streak camera measurements (*.img)
%   'optronis'       : Optronis streak camera measurements (*.imd)
%   'plate'          : Image plate measurementes (*.img)
%   'sbfp'           : Santa Barbara Focal Plan camera measurement (*.img)
%   'winspec'        : Princeton Instruments WinSpec measurements (*.spe)
%
% General binary formats:
%   'pff'            : Portable File Format files (*.pff)
%   'sda'            : Sanda Data Archive files (*.sda)
%
% See also FileAccess
%

%
% created Deceber 5, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=SupportedFormats()

list={};

list{end+1}='column';
list{end+1}='oceanoptics';
list{end+1}='optronicslab';
list{end+1}='optronicslabdump';

list{end+1}='agilent';
list{end+1}='dig';
list{end+1}='keysight';
list{end+1}='lecroy';
list{end+1}='saturn';
list{end+1}='tektronix';
list{end+1}='yokogawa';
list{end+1}='zdas';

list{end+1}='film';
list{end+1}='graphics';
list{end+1}='hamamatsu';
list{end+1}='optronis';
list{end+1}='plate';
list{end+1}='sbfp';
list{end+1}='winspec';

list{end+1}='pff';
list{end+1}='sda';

list=sort(list);

if nargout==0
    fprintf('Supported formats: \n');
    fprintf('\t%s\n',list{:});
else
    varargout{1}=list;
end

end