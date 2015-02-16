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
        FFToptions % FFT options object
        %Normalization = 'global' % Power spectrum normalization ('global' or 'none')
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
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
end