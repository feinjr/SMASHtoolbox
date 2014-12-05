% This class creates multiple-signal objects on a common time base.  These
% object are similar to Signal objects, but the "Data" property is a
% two-dimensional array.  Each column of this array represents the data for
% a particular signal in the group.  Many (but not all) Signal methods can
% be applied to SignalGroup objects.
%
% The most direct way to create a SignalGroup object is to pass numerical
% information directly.
%    >> object=SignalGroup(Grid,Data);
% Information can also be imported from a data file.
%    >> object=SignalGroup('import',filename,format);
% The input "filename" can either be a character array (single file) or
% cell array of character arrays (multiple files); in the latter case, each
% file must have the same format.  Multiple signals are automatially
% extracted from 'column' and 'sda' format files.
%
% Signals can be restored from previous objects saved by the "store"
% method.
%    >> object=SignalGroup('restore',filename,[record]);
% Restoring a previous object requires  a *.sda (Sandia Data Archive) file!
%
% See also SignalAnalysis, FileAccess.SupportedFormats
%

classdef SignalGroup < SMASH.SignalAnalysis.Signal
    properties (SetAccess=?SMASH.General.DataClass)
        NumberSignals =0 % Number of signals
    end
    properties
        Legend={};
    end
    %% hidden methods
    methods (Hidden=true)
        function object=SignalGroup(varargin)
            object=object@SMASH.SignalAnalysis.Signal(varargin{:}); % call superclass constructor
        end
        varargout=convolve(varargin)
        varargout=fft(varargin)
        varargout=align(varargin)
    end
    %% protected methods
    methods (Access=protected)
        varargout=create(varargin);
        varargout=import(varargin);
    end
    %% set methods
    methods
        function object=set.Legend(object,value)
            assert(iscell(value),'ERROR: invalid Legend');
            if isempty(object.Legend) || isempty(value) || (numel(value)==numel(object.Legend))
                object.Legend=value;
            else
                error('ERROR: invalid Legend');
            end
        end
    end
   
end