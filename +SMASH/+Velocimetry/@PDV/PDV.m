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
% See also SMASH.Velocimetry, SMASH.FileAccess.readFile, SMASH.SignalAnalysis.STFT,
% SMASH.ImageAnalysis.Image, SMASH.SignalAnalysis.SignalGroup
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
        NoiseAmplitude  % Time-domain RMS noise of the PDV measurement
    end
    properties
        AnalysisMode = 'robust' % Analysis mode
        Wavelength = 1550e-9 % Target wavelength
        ReferenceFrequency = 0 % Reference frequency
    end
    properties (Dependent=true)        
        Amplitude = {}   % Amplitude results (cell array of Signal objects)
        Frequency = {}   % Frequency results (cell array of Signal objects)
        Uncertainty = {} % Uncertainty results (cell array of Signal objects)
    end
    properties (SetAccess=protected,Hidden=true)
        NoiseDefined=false % Indicates if noise has been defined
        NoiseCharacterized=false % Indicates if noise has been characterized
        NoiseSignal % NoiseSignal object
        Analyzed=false; % Indicates if analysis has been performed
        AnalysisResult % cell array of SignalGroup objects [peak_location signal_amplitude effective_duration]
    end
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
        function object=set.AnalysisMode(object,value)
            assert(ischar(value),'ERROR: invalid analysis mode');
            value=lower(value);
            switch value
                case {'robust'}
                    % valid choice
                otherwise
                    error('ERROR: invalid analysis mode');
            end
        end
        function object=set.Wavelength(object,value)
            if isempty(value)
                % do nothing
            else
                assert(isnumeric(value) && isscalar(value) && isfinite(value),...
                    'ERROR: invalid Wavelength value');
            end
            object.Wavelength=value;
        end
        function object=set.ReferenceFrequency(object,value)
            if isempty(value)
                % do nothing
            else
                assert(isnumeric(value) && isscalar(value) && isfinite(value), ...
                    'ERROR: invalid ReferenceFrequency value');
            end
            object.ReferenceFrequency=value;
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
                rethrow(ME);
            end
        end
        function value=get.RemoveDC(object)
            value=object.STFT.FFToptions.RemoveDC;
        end
        function object=set.RemoveDC(object,value)
            try
                object.STFT.FFToptions.RemoveDC=value;
            catch ME
                rethrow(ME);
            end
        end
        function value=get.NumberFrequencies(object)
            value=object.STFT.FFToptions.NumberFrequencies;
        end
        function object=set.NumberFrequencies(object,value)
            try
                object.STFT.FFToptions.NumberFrequencies=value;
            catch ME
                rethrow(ME);
            end
        end
        function object=set.NoiseAmplitude(object,value)
            try
                object.NoiseSignal.Amplitude=value;
            catch
                error('ERROR: invalid NoiseAmplitude value');
            end   
            object.NoiseDefined=true;
        end
        function value=get.NoiseAmplitude(object)
            if object.NoiseDefined
                value=object.NoiseSignal.Amplitude;
            else
                error('ERROR: NoiseAmplitude has not been defined yet');
            end
        end
        function value=get.Frequency(object)
            if object.Analyzed
                value=object.AnalysisResult;
                for n=1:numel(value)
                    temp=split(value{n});
                    value{n}=temp;
                end
            else
                error('ERROR: analysis has not been performed yet');
            end
        end
        function value=get.Amplitude(object)
            if object.Analyzed
                value=object.AnalysisResult;
                for n=1:numel(value)
                    [~,temp]=split(value{n});
                    value{n}=temp;
                end
            else
                error('ERROR: analysis has not been performed yet');
            end
        end
        function value=get.Uncertainty(object)
            if object.Analyzed
                assert(object.NoiseDefined,'ERROR: noise amplitude is undefined');                
                t=object.STFT.Measurement.Grid;
                T=abs(t(end)-t(1))/(numel(t)-1);
                fs=1/T;
                value=object.AnalysisResult;
                for n=1:numel(value)
                    [~,amplitude,duration]=split(value{n});
                    value{n}=amplitude; % object copy
                    temp=sqrt(6./(fs*(duration.Data).^3))*object.NoiseAmplitude./amplitude.Data/pi;
                    %temp(isinf(temp))=fs/2;
                    value{n}=reset(value{n},[],temp);
                end
            else
                error('ERROR: analysis has not been performed yet');
            end
        end        
    end
end