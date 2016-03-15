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
    properties (SetAccess=protected)
        Measurement % PDV measurement (STFT object)
        Preview % Preview spectrogram (Image object)
        Settings % Analysis settings (structure)         
        Boundary = {} % ROI boundaries (BoundaryCurve object)
        Frequency % Analysis results (cell array of SignalGroup objects)
        Velocity % Converted results (cell array of SignalGroup objects)
    end
    properties
        GraphicOptions % Graphic optoins (GraphicOptions object)        
    end    
    properties (SetAccess=protected)        
        SampleRate
        MinimumWidth
        DomainScaling
    end
    %%
    methods (Hidden=true)
        function object=PDV(varargin)
            object=create(object,varargin{:});            
        end
        varargout=partition(varargin);
        %varargout=convert(varargin);
    end
    %%
    methods (Access=protected, Hidden=true)
        varargout=create(object,varargin);
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);        
    end   
end