% This class creates objects for analyzing Photonic Doppler Velocimetry
% (PDV) measurements.  
%
% PDV objects can be constructed from numeric input:
%     >> object=PDV(time,signal); % time/signal are 1D arrays
% or by loading data from a file.
%     >> object=PDV(filename,format,record); % inputs passed to "readFile" 
% The actual PDV signal is stored in the object's Measurement property as a
% STFT sub-object. A preview spectrogram can be stored in a separate
% property as an Image sub-object.  Settings and results are stored in
% separate structure arrays.
%
% History extraction is the ultimate purpose of the PDV class.  Once signal
% processing, frequency bounding, and setting configuration is complete,
% the "analyze" method tracks spectral features as a function of time.
%
% See also Velocimetry, FileAccess.readFile, SignalAnalysis.STFT,
% ImageAnalysis.Image, SignalAnalysis.SignalGroup
%

%
% created February 18, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef PDV
    %%
    properties
        STFT % PDV measurement (STFT object)
        Preview % Preview spectrogram (Image object)
        Boundary = {} % ROI boundaries (BoundaryCurve object)
    end
    properties (Dependent=true)
        Window % FFT window name ('hann', 'hamming', 'boxcar')
        RemoveDC % Remove DC level before FFT (logical)
        NumberFrequencies % Number of frequency points in FFT [min max]
    end
    properties
        Bandwidth % Measurement bandwidth
        RMSnoise  % Time-domain RMS noise of the PDV measurement
    end
    properties (SetAccess=protected)           
        Frequency = {} % Analysis results (cell array of SignalGroup objects)              
        Velocity = {} % Converted results (cell array of SignalGroup objects)       
    end
    properties
        GraphicOptions % Graphic options (GraphicOptions object)        
    end    
%     properties (SetAccess=protected,Hidden=true)        
%         SampleInterval
%         SampleRate
%         DomainScaling
%         Duration
%         EffectiveDuration
%         EffectiveWidth
%     end
    %%
    methods (Hidden=true)
        function object=PDV(varargin)
            object=create(object,varargin{:});            
        end
    end   
    methods (Access=protected, Hidden=true)
        varargout=create(varargin);
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);        
    end
    %% setters
    methods
        function object=set.STFT(object,value)
            assert(strcmpi(class(value),'SMASH.SignalAnalysis.STFT'),...
                'ERROR: invalid STFT value');
            object.STFT=value;
        end
        function object=set.Preview(object,value)
            assert(strcmpi(class(value),'SMASH.ImageAnalysis.Image'),...
                'ERROR: invalid Preview value');
            object.Preview=value;
        end
        function object=set.Boundary(object,value)
            assert(iscell(value),'ERROR: invalid Boundary value');
            for n=1:numel(value)
                assert(strcmpi(class(value{n}),'SMASH.ROI.BoundingCurve'),...
                    'ERROR: invalid Boundary value');
            end
            object.Boundary=value;
        end
        function object=set.Bandwidth(object,value)
            if isempty(value)
                % do nothing
            else
                assert(isnumeric(value) && isscalar(value),...
                    'ERROR: invalid Bandwidth value');
            end
            object.Bandwidth=abs(value);
        end
        function object=set.RMSnoise(object,value)
            if isempty(value)
                % do nothing
            else
                assert(isnumeric(value) && isscalar(value),...
                    'ERROR: invalid RMSnoise value');
            end
            object.RMSnoise=abs(value);
        end
    end
    %% setters/getters for dependent properties
    methods
        function value=get.Window(object)
            value=object.STFT.FFToptions.Window;
        end
        function object=set.Window(object,value)
            try
                object.STFT.FFToptions.Window=value;
            catch ME
                throwAsCaller(ME);
            end
        end
        function value=get.RemoveDC(object)
            value=object.STFT.FFToptions.RemoveDC;
        end
        function object=set.RemoveDC(object,value)
            try
                object.STFT.FFToptions.RemoveDC=value;
            catch ME
                throwAsCaller(ME);
            end
        end
        function value=get.NumberFrequencies(object)
            value=object.STFT.FFToptions.NumberFrequencies;
        end
        function object=set.NumberFrequencies(object,value)
            try
                object.STFT.FFToptions.NumberFrequencies=value;
            catch ME
                throwAsCaller(ME);
            end
        end
    end
end