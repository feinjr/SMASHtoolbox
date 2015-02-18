% This class creates objects for analyzing Photonic Doppler Velocimetry
% (PDV) measurements.  
%
% PDV objects can be constructed from numeric input:
%     >> object=PDV(time,signal); % time/signal are 1D arrays
% or by loading data from a file.
%     >> object=PDV(filename,format,record); % inputs passed to "readFile" 
% The PDV signal is stored as a STFT sub-object as the Measurement
% property.  Properties and methods of the subobject can be accessed at any
% time.
%     >> object.Measurement.FFToptions.Window='boxcar';
%     >> view(object.Measurement);
% The Measurement property can be replaced with another STFT sub-object;
% dependent properties, such as Preview, are *not* updated automatically.
%
% Preview
%
% Bound
%
% Track
%
% Convert
%
% See also Velocimetry, FileAccess.readFile, SignalAnalysis.STFT,
% SignalAnalysis.SignalGroup, ImageAnalysis.Image

%
% created ?
%
classdef PDV
    %%
    properties
        Parameter % System parameter structure
        %NoiseFraction % Noise fraction table [time sigma]
        Measurement % STFT object
    end
    properties (SetAccess=protected)
        Preview % Preview Image object
        Boundary = {} %  BoundaryCurveGroup object
        History % History SignalGroup object
        BeatFrequency % SignalGroup object
        Uncertainty % SignalGroup object        
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
    end
end