%
%
% created February 24, 2017 by Adam Harvey-Thompson (Sandia National Laboratories)
%
classdef Power
    %% properties
    properties % core data
        Shot;
        RawSignal; % SignalGroup object
        ProcessedSignal; % SignalGroup object - contains smoothing and other processes applied to RawSignal
        SourcePower; % Signal object - power radiated by source that is seen by element. calculatePower operates on ProcessedSignal object
        Settings; % Cell array of settings
        AbsorptionCurve; % Signal group object
        Spectrum; % Signal object
        AnalysisSummary;% Cell array of numbers summarizing analysis
    end
     

    
    %% constructor
    methods;
        function object=Power(varargin);
            
    object.Settings = cell(15,10)
    object.Settings(1:15,1) = {'Signal name';'Element type';'Element size';'Element sensitivity (A/W)';'Source distance (m)';...
        'Filter material';'Filter thickness (um)'; 'Source height';'Aperture height'; 'Noise limits';'Integration limits';'Baseline correction';'Noise RMS';...
        'Geometry correction';'Distance correction'}   

    object.AnalysisSummary = cell(14,10)
    object.AnalysisSummary(1:14,1) = {'Signal name';'Element type';'Filter material';'Filter thickness (um)';'Normalization factor';'Energy bounds (eV)';...
        'Energy absorbed by detector (eV)';'Detector area (mm^2)';'Filtered energy into 4pi (J)';'Total energy into 4pi (J)';'Peak power into 4pi (J)'; 'Peak power time (ns)'; 'Power FWHM (ns)';'Fractional error'}   

    
            if (nargin==1) && ischar(varargin{1});
                varargin{1}=SMASH.SignalAnalysis.SignalGroup(varargin{1});
                object.RawSignal=varargin{1};
                %object.BiasCorrectedSignal = SMASH.SignalAnalysis.Signal(varargin{:});
            elseif (nargin == 1) && isobject(varargin{1});
                object.RawSignal=varargin{1};
            end
        end
    end
    methods (Hidden=false);
        varargout = getInfo(varargin);
        varargout = calculateAbsorption(varargin);
        varargout = calculatePower(varargin);
        varargout = restore(varargin);
        varargout = integrateSignal(varargin);  
        varargout = pickTimes(varargin);  
        varargout = pickSignal(varargin);  
        varargout = normalizeSpectrum(varargin);        
    end
    
end