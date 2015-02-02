% This class creates objects for analysis and visualization of
% one-dimensional scalar information.  The dependent variable is stored as
% the "Data" property; the independent variable is stored in the "Grid"
% property.
%
% Signal objects may be constructed from two numerical inputs.
%    >> object=Signal(x,y);
% The first input is the grid (independent) array, while the second input
% is the data (dependent) array.  Typically, inputs "x" and "y" have the
% same number of elements.  Input "x" can be empty, in which case the
% object's Grid property is assigned to set of ascending integers (starting
% at 1).  Input "x" can also be a scaler, which is interpreted
% as the step size for the object's Grid property (starting from 0).
%
% Signal objects can also be created from a file.
%    >> object=Signal(); % interactive file selection
%    >> object=Signal(filename,[format],[record]);
% File arguments ("format" and "record") are passed to the
% FileAccess.readFile function.  These inputs should be used when the
% file's extension corresponds to multiple formats or the file contains
% multiple records.
%
% See also SignalAnalysis, FileAccess.readFile, FileAccess.SupportedFormats
%

% is this necessary anymore?
% Signals can be restored from previous objects saved by the "store"
% method.
%    >> object=Signal(archive,record);
% The file specifed by "archive" must have a *.sda (Sandia Data Archive)
% file!


%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboraties)
% revised April 21, 2014 by Daniel Dolan
%    -removed the 'import' argument requirement
% revised November 2, 2014 by Daniel Dolan
%    -simplified creator by using new DataClass paradigm
% revised January 30 by Daniel Dolan
%    -expanded PFF support
classdef Signal < SMASH.General.DataClass
    %%
    properties (SetAccess=?SMASH.General.DataClass) % superclass, class, and subclass access
        Grid = [] % Independent array
        LimitIndex='all' % Limited region
    end
    properties (Access=?SMASH.General.DataClass,Hidden=true)
        ReservedNames={'fancy'};       
    end
    properties (SetAccess={?SMASH.General.DataClass},...% superclass, class, and subclass access
            Hidden=true)
        GridDirection % 'normal' for increasing, 'reverse' for decreasing
        GridUniform % true for uniform grid spacing
        GridSpacing % average grid spacing
    end
    properties
        GridLabel='Grid' % Default XLabel
    end
    %% hidden methods
    methods (Hidden=true) % constructor
        function object=Signal(varargin)
            object=object@SMASH.General.DataClass(varargin{:}); % call superclass constructor
            object=verifyGrid(object);
        end
    end
    methods (Hidden=true)
        varargin=makeGridUniform(varargin);
        varargout=verifyGrid(varargin);
    end
    %% protected methods
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);
    end
    %% property setters
    methods
        function object=set.GridLabel(object,value)
            if ischar(value)
                object.GridLabel=value;
            else
                error('ERROR: GridLabel must be character array');
            end
        end                
    end
    
end