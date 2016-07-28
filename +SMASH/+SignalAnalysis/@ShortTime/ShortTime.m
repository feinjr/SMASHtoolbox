% This class creates ShortTime objects for local analysis of
% one-dimensional information.  ShortTime objects are created from Signal
% objects or the information needed to create a Signal object.
%    object=ShortTime(source); % build from a source Signal
%    object=ShortTime(Grid,Data); % build from numeric data
%    object=ShortTime(filename,format,record); % build from file
% Signal information is stored in the Measurement property.
%
% See also SMASH.SignalAnalysis, SMASH.SignalAnalysis.Signal,
% SMASH.FileAccess.SupportedFormats
%

%
% created April 8, 2014 by Daniel Dolan (Sandia National Laboratories)
% signficantly revised June 26, 2016 by Daniel Dolan
%    -ShortTime is no longer a subclass of Signal, but instead sotres a
%    Signal object inside the Measurement property.
%
classdef ShortTime
    %%
    properties
        Measurement % Measured signal (SMASH.SignalAnalysis.Signal object)
        Name = 'ShortTime object' % Object name (text)
    end
    properties (SetAccess=protected)
        Comments = '' % Object comments (text).  Modify with the comment method
        Partition % Analysis partition settings (structure). Modify with the partition method
    end  
    properties
        ShowWaitbar=false % Enable/disable waitbar display (logical)
        WaitbarIncrement=0.05 % Progress steps on waitbars (0-1, exclusive)
    end
    %%
    methods (Hidden=true)
        function object=ShortTime(varargin)
            if (nargin==1)
                if strcmpi(varargin{1},'-empty')
                    return % this mode is for subclass constructors
                end
                switch class(varargin{1})
                    case 'SMASH.SignalAnalysis.Signal'
                        object.Measurement=varargin{1};
                    case 'SMASH.SignalAnalysis.ShortTime'   
                        object=varargin{1};
                        return
                end
                try
                    object.Measurement=SMASH.SignalAnalysis.Signal(varargin{:});
                end
            else
                object.Measurement=SMASH.SignalAnalysis.Signal(varargin{:});
            end
            object.Measurement=regrid(object.Measurement);                
            object.Measurement.GraphicOptions.Title='ShortTime object';
            object.Measurement.GridLabel='Time';
            object.Measurement.DataLabel='Signal';
            object=partition(object,'Blocks',[10 0]);
        end
    end   
    %% protected methods
    methods (Access=protected, Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
        varargout=convert(varargin);
    end
    %% setters
    methods
        function object=set.Measurement(object,value)
            assert(isa(value,'SMASH.SignalAnalysis.Signal'),...
                'ERROR: invalid Measurement value');
            object.Measurement=value;
        end
        function object=set.Name(object,value)
            assert(ischar(value),'ERROR: invalid name');
            object.Name=value;
        end
        function object=set.ShowWaitbar(object,value)
            try
                value=logical(value);
                assert(isscalar(value));
            catch
                error('ERROR: invalid ShowWaitbar value');
            end
            object.ShowWaitbar=value;
        end
        function object=set.WaitbarIncrement(object,value)
            assert(SMASH.General.testNumber(value) && (value>0) && (value<1),...
                'ERROR: invalid WaitbarIncrement value');
            object.WaitbarIncrement=value;
        end
    end
end