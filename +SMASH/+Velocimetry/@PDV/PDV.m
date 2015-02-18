% This class creates objects for analyzing Photonic Doppler Velocimetry
% (PDV) measurements.  
%
% PDV objects can be constructed from numeric input:
%     >> object=PDV(time,signal); % time/signal are 1D arrays
% or by loading data from a file.
%     >> object=PDV(filename,format,record); % inputs passed to "readFile" 
% The PDV signal is stored as a STFT sub-object in the Measurement
% property.  Measurement methods can be accessed, and Measurement
% properties can be accessed/modified.
%     >> time=object.Measurement.Grid; % access time grid
%     >> object.Measurement.FFToptions.Window='boxcar'; % change FFT Window
%     >> view(object.Measurement); % Signal display
%
% A preview spectrogram can be associated with a PDV object for
% visualization.
%     >> object=preview(object); % generate preview
%     >> preview(object); % display preview
% The spectrogram is stored as an Image sub-object in the Preview property.
%  Preview properties and methods can be accessed:
%     >> frequency=object.Preview.Grid2; % access frequency grid
%     >> view(object.Preview); % Image display
% but the Preview properties cannot be modified directly.
%
% History analysis tracks the strongest feature(s) in the measurement. 
%     >> object=analyze(object);
% The default analysis trackes a single feature over the entire frequency
% range, but several independent features (each with dynamic frequency
% bounds) can be selected.
%     >> object=bound(object); % interactive boundary selection
%     >> object=analyze(object);
% Tracked frequency results are stored in the History property.
%
% Frequencies are converted to velocity immediately after analysis.  By
% default, this conversion uses the wavelength and reference frequency
% parameters.
%       velocity = (wavelength/2) * (frequency-ReferenceFrequency);
% This conversion can be replaced with a custom function *prior* to analysis.
%     >> object.ConvertFunction=@myfunc;
% The function handle "myfunc" must accept a single input and return a
% single output, e.g. "function velocity=myfunc(frequency)".  


%
% To convert beat frequency to velocity:
%     >> object=convert(object); % standard conversion
%     >> object=convert(object,@myfunc); % custom conversion
% Wavelength and reference frequency settings specified in the Parameters
% property.  For graphical display:
%     >> view(
%
% See also Velocimetry, FileAccess.readFile, SignalAnalysis.STFT,
% SignalAnalysis.SignalGroup, ImageAnalysis.Image

%
% created February 18, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef PDV
    %%
    properties
        Measurement % PDV measurement (STFT object)
        Parameter % System parameters (structure)
        MapFrequency % Frequency mapper (function handle)
        ConvertFunction % Frequency to velocity conversion (function handle)
    end
    properties (SetAccess=protected)
        Preview % preview spectrogram (Image object)
        Boundary = {} % Track boundaries (cell array of BoundaryCurveGroup objects)
        History % Peak histories (SignalGroup object)
        Velocity % Velocity results (cell array of SignalGroup objects)
    end
    %%
    methods (Hidden=true)
        function object=PDV(varargin)
            % default parameters     
            parameter.Wavelength=1550e-9;
            parameter.ReferenceFrequency=0;
            parameter.Bandwidth=[];
            parameter.NoiseFloor=0;
            parameter.BasisTolerance=1e-3; 
            object.Parameter=parameter;
            % manage input
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=SMASH.SignalAnalysis.STFT(varargin{1});
                object.Measurement=varargin{1};
            elseif (nargin>0) && ischar(varargin{1})
                temp=SMASH.FileAccess.readFile(varargin{:});
                switch class(temp)
                    case 'SMASH.Velocimetry.PDV'
                        object=temp;
                    otherwise
                        object.Measurement=SMASH.SignalAnalysis.STFT(varargin{:});
                end
            else
                object.Measurement=SMASH.SignalAnalysis.STFT(varargin{:});
            end
        end
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    %% setters
    methods
        function object=set.Parameter(object,value)
            assert(isstruct(value),'ERROR: invalid Parameter setting');
            if ~isempty(object.Parameter)
                name=fieldnames(value);
                for k=1:numel(name)
                    assert(isfield(object.Parameter,name{k}),...
                        'ERROR: "%s" is not a valid Parameter',name{k});
                end
            end
            object.Parameter=value;
        end
        function object=set.Measurement(object,value)
            assert(isa(value,'SMASH.SignalAnalysis.STFT'),...
                'ERROR: invalid Measurement setting')
            object.Measurement=value;
        end
        function object=set.ConvertFunction(object,value)
            assert(isa(value,'function_handle'),...
                'ERROR: invalid ConvertFunction value');
            object.ConvertFunction=value;
        end
    end
end