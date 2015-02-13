% This class creates ShortTime objects for local analysis of
% one-dimensional scalar information.  Objects created  with this class
% have all properties/methods of the Signal superclass as well as the
% following capabilities.
%    -The "partition" method partitions the objects' Grid into local regions.
%    -The "analyze" method applies a specified function to these regions.
% For more information, refer the documentation for each method.
%
% The most direct way to create a ShortTime object is to pass numerical
% information directly.
%    >> object=ShortTime(Grid,Data);
% Information can also be imported from a data file.
%    >> object=ShortTime('import',filename,format,[record]);
%
% Signals can be restored from previous objects saved by the "store"
% method.
%    >> object=ShortTime('restore',filename,[record]);
% Restoring a previous object requires  a *.sda (Sandia Data Archive) file!
%
% See also Signal, FileAccess.SupportedFormats
%

%
% created April 8, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef ShortTime < SMASH.SignalAnalysis.Signal
    %%
    properties (SetAccess=?SMASH.General.DataClass)
        Partition; % Analysis partition structure  
    end  
    properties (Hidden=true)
        ShowWaitbar=false % Enable/disable waitbar display
        WaitbarIncrement=0.05 % Progress steps on waitbars
    end
    %%
    methods (Hidden=true)
        function object=ShortTime(varargin)
            object=object@SMASH.SignalAnalysis.Signal(varargin{:});
            object=makeGridUniform(object); % force uniform Grid spacing
            if isempty(object.Partition)
                object=partition(object,'blocks',[1000 0]);
            end
        end
    end
    %% protected methods
    methods (Access=protected)
        varargout=create(varargin);
        varargout=import(varargin);
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
end