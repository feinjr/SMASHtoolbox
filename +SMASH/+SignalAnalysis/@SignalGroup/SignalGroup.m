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
%    >> object=SignalGroup(filename,[format],[record]);
% The inputs "format" and "record" may be optional depending on the file's
% format and contents.  If the file name contains a wild card ('*.sda')
% that matches more than one file, the object is contructed from the sum of
% the individual files (consistent size required).
%
% See also SignalAnalysis, FileAccess.SupportedFormats
%

%
%
%
classdef SignalGroup < SMASH.SignalAnalysis.Signal
    properties (SetAccess=?SMASH.General.DataClass)
        NumberSignals = 0 % Number of signals
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
        varargout=register(varargin)
    end
    %% protected methods
    methods (Access=protected)
        varargout=create(varargin);
        varargout=import(varargin);
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    %% set methods
    methods
        function object=set.Legend(object,value)
            assert(iscell(value),'ERROR: invalid Legend');
            %if isempty(object.Legend) || isempty(value) || (numel(value)==numel(object.Legend))
                object.Legend=value;
            %else
            %    error('ERROR: invalid Legend');
            %end
        end
    end
   
end