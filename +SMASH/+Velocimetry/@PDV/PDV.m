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
% History analysis is the ultimate purpose of the PDV class.  Once signal
% processing, frequency bounding, and setting configuration is complete,
% the "analyze" method tracks spectral features as a function of time.
%
% See also Velocimetry, FileAccess.readFile, SignalAnalysis.STFT,
% ImageAnalysis.Image

%
% created February 18, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef PDV
    %%
    properties
        Measurement % PDV measurement (STFT object)        
        Preview % Preview spectrogram (Image object)
    end
    properties (SetAccess=protected)
        Settings % Analysis settings (structure)
        Results  % Analysis results (structure) 
        Boundary = {} % ROI boundaries (BoundaryCurve object)
    end
    %%
    methods (Hidden=true)
        function object=PDV(varargin)
            % default settings
            p=struct();
            p.Wavelength=1550e-9;
            p.ReferenceFrequency=0;
            %p.NoiseRegion=[]; % [tmin tmax fmin fmax]  
            p.NoiseAmplitude=[];
            p.UniqueTolerance=1e-3;         
            p.ConvertFunction=[];
            p.HarmonicFunction={};
            p.ShockTable=[];
            object.Settings=p;
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
            object.Measurement.Name='PDV measurement';
            object.Measurement.GraphicOptions.Title='PDV measurement';
        end
        varargout=partition(varargin);
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end   
    %% setters
    methods
        function object=set.Measurement(object,value)
            assert(isa(value,'SMASH.SignalAnalysis.STFT'),...
                'ERROR: Measurement property must be a STFT object');
            object.Measurement=value;
        end
        function object=set.Preview(object,value)
            assert(isa(value,'SMASH.ImageAnalysis.Image'),...
                'ERROR: Preview property must be an Image object');
            object.Preview=value;
        end        
    end
end