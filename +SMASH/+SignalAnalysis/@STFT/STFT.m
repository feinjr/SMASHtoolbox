% This class creates Short Time Fourier Transform (STFT) objects for
% representing the time-frequency content of a signal.  Many of the
% properties and methods of this class are derived from the Signal class.
% Additions specific to STFT are noted below.
%   Properties:
%    -
%
% See also Signal, FileAccess.SupportedFormats
%

% (NF-1)*2=N2

classdef STFT < SMASH.SignalAnalysis.ShortTime
    %%
    properties
        FFToptions % FFT options
        Normalization = 'global' % Power spectrum normalization ('global','local', or 'none')
    end
    properties
        Preview % preview Image
    end    
    properties (SetAccess=?SMASH.General.DataClass) 
        Boundary = {} % cell array of BoundingCurve objects
    end   
    %%
    methods (Hidden=true)
        function object=STFT(varargin)
            object=object@SMASH.SignalAnalysis.ShortTime(varargin{:}); 
        end
    end
     %% protected methods
    methods (Access=protected, Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);
        varargout=initialize(varargin);
    end
    %% property setters
    methods
        function object=set.Normalization(object,value)
            if isempty(value)
                value='global';
            end
            assert(ischar(value),'ERROR: invalid Normalization setting');
            switch lower(value)
                case {'global','local','none'}
                    object.Normalization=value;
                otherwise
                    error('ERROR: invalid Normalization setting');
            end
        end                        
    end
end