% This class creates objects for analyzing Photonic Doppler Velocimetry
% (PDV) measurements.  
%
% PDV objects can be constructed from numeric input:
%    object=PDV(time,signal); % time/signal are 1D arrays
% or by loading data from a file.
%    object=PDV(filename,format,record); % inputs passed to "readFile" 
% The actual PDV signal is stored as an object in the STFT property;
% preview spectrogram can also stored.  
% 
% The ultimate purpose of this class is the "analyze" method, which
% processes signal data to determine beat frequency/amplitude and velocity.
% Analysis results are stored as cell arrays of Signal objects.
%
% NOTE: property changes may reset analysis results stored in the object.
% These changes may be explicit:
%    object.BoundaryType='loose';
% or implicit.
%    object=bound(object);
% The Analyzed property indicates if analysis has been performed for the
% current property state.  Property changes that do *not* require
% reanalysis include Comments (via the comment method), Name, Preview,
% NoiseAmplitude, Wavelength, and ReferenceFrequency.
%
% See also SMASH.Velocimetry, SMASH.FileAccess.readFile, SMASH.SignalAnalysis.STFT,
% SMASH.ImageAnalysis.Image, SMASH.SignalAnalysis.Signal
%

%
% created February 18, 2015 by Daniel Dolan (Sandia National Laboratories)
% substantially revised March 20, 2017 by Daniel Dolan
%
classdef PDV
    %%    
    properties (SetAccess=protected)
        Comments = '' % User comments (long description)
    end
    properties
        Name = 'PDV object' % Object name (short description)
    end
    %%    
    properties (Dependent=true)
        STFT % PDV measurement (STFT object)
        Preview % Preview spectrogram (Image object)
        Boundary = {} % ROI boundaries (BoundaryCurve object)
        BoundaryType  % Boundary type: 'loose' or 'strict'
        AnalysisMode % Analysis mode : 'robust'
    end
    properties (SetAccess=protected, Dependent=true)
        Analyzed % Indicates if analysis performed and current (logical)
    end
    properties (Access=private)
        PrivateSTFT
        PrivatePreview
        PrivateBoundary
        PrivateBoundaryType = 'loose'
        PrivateAnalysisMode = 'robust'
        PrivateAnalyzed = false
    end
    %%
    properties (Dependent=true)
        Window % FFT window name ('hann', 'hamming', 'boxcar')
        RemoveDC % Remove DC level before FFT (logical)
        NumberFrequencies % Number of frequency points in FFT [min max]
        NoiseAmplitude  % Time-domain RMS noise of the PDV measurement    
    end 
     properties
        Wavelength = 1550e-9 % Target wavelength
        ReferenceFrequency = 0 % Reference frequency
    end
    properties (Dependent=true,SetAccess=protected)        
        Amplitude = {}   % Amplitude results (cell array of Signal objects)
        Frequency = {}   % Frequency results (cell array of Signal objects)
        FrequencyUncertainty = {} % Frequency uncertainty results (cell array of Signal objects)
        Velocity = {} % Velocity results (cell array of Signal objects)
        VelocityUncertainty = {} % Velocity uncertainty results (cell array of Signal objects)
    end
    properties (SetAccess=protected,Hidden=true)
        NoiseDefined=false % Indicates if noise has been defined
        NoiseCharacterized=false % Indicates if noise has been characterized
        NoiseSignal % NoiseSignal object
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
        function object=set.Name(object,value)
            assert(ischar(value),'ERROR: invalid Name');
            object.Name=value;
        end
        %%
        function object=set.STFT(object,value)
            assert(strcmpi(class(value),'SMASH.SignalAnalysis.STFT'),...
                'ERROR: invalid STFT value');
            object.PrivateSTFT=value;
            object.Analyzed=false;
        end
        function value=get.STFT(object)
            value=object.PrivateSTFT;
        end 
        %%
        function object=set.Preview(object,value)
            if isempty(value)
                % continue
            else
                assert(strcmpi(class(value),'SMASH.ImageAnalysis.Image'),...
                    'ERROR: invalid Preview value');
            end
            object.PrivatePreview=value;
        end
        function value=get.Preview(object)
            value=object.PrivatePreview;
        end
        %%
        function object=set.Boundary(object,value)
            if isempty(value)
                % continue
            else
                assert(iscell(value),'ERROR: invalid Boundary value');
                for n=1:numel(value)
                    assert(strcmpi(class(value{n}),'SMASH.ROI.BoundingCurve'),...
                        'ERROR: invalid Boundary value');
                end
            end
            object.PrivateBoundary=value;
            object.Analyzed=false;
        end
        function value=get.Boundary(object)
            value=object.PrivateBoundary;
        end
        %%
        function object=set.BoundaryType(object,value)
            assert(ischar(value),'ERROR: invalid boundary type');
            value=lower(value);
            switch value
                case {'loose' 'strict'}
                    object.PrivateBoundaryType=value;
                otherwise
                    error('ERROR: invalid boundary type');
            end
            object.Analyzed=false;
        end
        function value=get.BoundaryType(object)
            value=object.PrivateBoundaryType;
        end
        %%
        function object=set.AnalysisMode(object,value)
            assert(ischar(value),'ERROR: invalid analysis mode');
            value=lower(value);
            switch value
                case {'robust'}
                    % valid choice
                otherwise
                    error('ERROR: invalid analysis mode');
            end
            object.PrivateAnalysisMode=value;
            object.Analyzed=false;
        end
        function value=get.AnalysisMode(object)
            value=object.PrivateAnalysisMode;
        end
        %%
        function object=set.Analyzed(object,value)
            assert(islogical(value),'ERROR: invalid Analyzed value');
            object.PrivateAnalyzed=value;
            if ~value
                object.AnalysisResult=[];
            end
        end
        function value=get.Analyzed(object)
            value=object.PrivateAnalyzed;
        end
        %%
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
            old=object.STFT.FFToptions.Window;
            try
                object.STFT.FFToptions.Window=value;
            catch ME
                rethrow(ME);
            end
            if ~strcmpi(old,value)       
                object.Analyzed=false;
            end
        end
        function value=get.RemoveDC(object)
            value=object.STFT.FFToptions.RemoveDC;
        end
        function object=set.RemoveDC(object,value)
            old=object.STFT.FFToptions.RemoveDC;
            try
                object.STFT.FFToptions.RemoveDC=value;
            catch ME
                rethrow(ME);
            end
            if ~strcmp(old,value)
                object.Analyzed=false;
            end
        end
        function value=get.NumberFrequencies(object)
            value=object.STFT.FFToptions.NumberFrequencies;
        end
        function object=set.NumberFrequencies(object,value)
            old=object.STFT.FFToptions.NumberFrequencies;
            try
                object.STFT.FFToptions.NumberFrequencies=value;
            catch ME
                rethrow(ME);
            end
            if ~strcmp(old,value)
                object.Analyzed=false;
            end
        end
        function object=set.NoiseAmplitude(object,value)
            try
                object.NoiseSignal.Amplitude=value;
            catch
                error('ERROR: invalid NoiseAmplitude value');
            end
            object.NoiseDefined=true;
            if ~object.NoiseCharacterized
                warning('SMASH:PDV','Setting noise amplitude without characterization may yield invalid uncertainties');
            end
        end
        function value=get.NoiseAmplitude(object)
            if object.NoiseDefined
                value=object.NoiseSignal.Amplitude;
            else
                value='(undefined)';
            end
        end
        function value=get.Amplitude(object)
            if object.Analyzed
                value=object.AnalysisResult;
                for n=1:numel(value)
                    name=value{n}.Name;
                    [~,temp]=split(value{n});
                    value{n}=temp;
                    value{n}.Name=name;
                end
            else
                value='(undefined)';
            end
        end
        function value=get.Frequency(object)
            if object.Analyzed               
                value=object.AnalysisResult;
                for n=1:numel(value)
                    name=value{n}.Name;
                    temp=split(value{n});
                    value{n}=temp;
                    value{n}.Name=name;
                end
            else
                value='(not analyzed yet)';                
            end
        end        
        function value=get.FrequencyUncertainty(object)
            if object.Analyzed
                if ~object.NoiseDefined
                    value='(undefined)';
                    return
                end
                t=object.STFT.Measurement.Grid;
                T=abs(t(end)-t(1))/(numel(t)-1);
                fs=1/T;
                value=object.AnalysisResult;
                for n=1:numel(value)
                    name=value{n}.Name;
                    [~,amplitude,duration]=split(value{n});
                    value{n}=amplitude; % object copy
                    temp=sqrt(6./(fs*(duration.Data).^3))*object.NoiseAmplitude./amplitude.Data/pi;
                    %temp(isinf(temp))=fs/2;
                    value{n}=reset(value{n},[],temp);
                    value{n}.DataLabel='Frequency uncertainty';
                    value{n}.Name=name;
                end
            else
                value='(not analyzed yet)';
            end
        end
        function value=get.Velocity(object)
            if object.Analyzed
                value=object.Frequency;
                for n=1:numel(value)
                    name=value{n}.Name;
                    value{n}=object.Wavelength/2*(value{n}-object.ReferenceFrequency);
                    value{n}.DataLabel='Velocity';
                    value{n}.Name=name;
                end
            else
                value='(not analyzed yet)'; 
            end
        end
        function value=get.VelocityUncertainty(object)
            if object.Analyzed
                if ~object.NoiseDefined
                    value='(undefined)';
                    return
                end
                value=object.FrequencyUncertainty;
                for n=1:numel(value)
                    name=value{n}.Name;
                    value{n}=object.Wavelength/2*value{n};
                    value{n}.DataLabel='Velocity uncertainty';
                    value{n}.Name=name;
                end
            else
                value='(not analyzed yet)';     
            end
        end
    end
end