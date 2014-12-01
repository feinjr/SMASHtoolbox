% ImageFile Class for managing access to various image formats
%
% Syntax:
%    >> object=DigitizerFile([filename],[format]);
% Supported formats include:
%    'graphics'  - Graphic image files (*, bmp, *.jpg, *.tif, etc.)
%    'winspec'   - WinSpec image files (*.spe)
%    'optronis'  - Optronics streak camera files (*.spe)
%    'film'      - Film scans (*.img, *.hdf, *.pff)
%    'plate'     - Image plate scans (*.img)
% When no format is specified, the class tries to determine the format
% based on the file's extension.  Users will be prompted to select a format
% if multiple formats are associated with this extension.
%
% See also FileAccess, probe, read, select
%

%
classdef ImageFile < SMASH.FileAccess.File
    properties (SetAccess=protected)
        Format
    end
    properties (Hidden=true)
        FilterSpec={...
            ['*.spe;*.SPE;*.imd;*.IMD' ...
            '*.bmp;*.BMP;*.img;*.IMG;*.hdf;*.HDF;*.pff;*.PFF' ...
            '*.jpg;*.JPG;*.jpeg;*.JPEG;*.tif;*.TIF;*.tiff;*.TIFF;*.png;*.PNG']...
            ,'Image files';...
            '*.*','All files';};
    end
    %%
    methods (Hidden=true)
        function object=ImageFile(filename,format)            
            object=object@SMASH.FileAccess.File();
            if nargin<1
                filename='';
            end
            if nargin<2
                format='';
            end
            object=select(object,filename,format);            
        end
        varargout=select(varargin);
    end
end