% This class creates objects for analysis and visualization of
% one-dimensional scalar information.  The dependent variable is stored as
% the "Data" property; the independent variable is stored in the "Grid"
% property.
%
% The most direct way of creating a Signal object is to pass two numerical
% arrays.
%    >> object=Signal(x,y);
% The first input is the grid (independent) array, while the second input
% is the data (dependent) array.  Typically, inputs "x" and "y" have the
% same number of elements.  Input "x" can be empty, in which case the
% object's Grid property is assigned to set of ascending integers (starting
% at 1).  Input "x" can also be assigned to a single number, which is used
% as the step size for the object's Grid property (which starts at 0).
%
% Signal objects can be created by importing information from a file.
%    >> object=Signal(); % interactive file selection
%    >> object=Signal(filename,[format],[record]);
% The inputs "format" and "record" may be optional depending on the file's
% format and contents.
%
% Signals can be restored from previous objects saved by the "store"
% method.
%    >> object=Signal(archive,rcord);
% The file specied by "archive" must have a *.sda (Sandia Data Archive)
% file!
%
% See also SignalAnalysis, FileAccess.SupportedFormats
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboraties)
% revised April 21, 2014 by Daniel Dolan
%    -removed the 'import' argument requirement
% revised November 2, 2014 by Daniel Dolan
%    -simplified creator by using new DataClass paradigm
classdef Signal < SMASH.General.DataClass
    %%
    properties (SetAccess=?SMASH.General.DataClass) % superclass, class, and subclass access
        Grid = [] % Independent array
    end
    properties (Access=?SMASH.General.DataClass,Hidden=true)
        ReservedNames={'fancy'};
    end
    properties (SetAccess={?SMASH.General.DataClass},...% superclass, class, and subclass access
            Hidden=true)
        LimitIndex='all' % Region of interest
        GridDirection % 'normal' for increasing, 'reverse' for decreasing
        GridUniform % true for uniform grid spacing
        GridSpacing % average grid spacing
    end
    properties
        GridLabel='Grid' % Default XLabel
        Title='' % Default Title
    end
    %% hidden methods
    methods (Hidden=true) % constructor
        function object=Signal(varargin)
            object=object@SMASH.General.DataClass(varargin{:}); % call superclass constructor
            object=concealProperty(object,'LimitIndex');
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
        function object=set.Title(object,value)
            if ischar(value)
                object.Title=value;
            else
                error('ERROR: Title must be character array');
            end
        end
        
    end
    
end