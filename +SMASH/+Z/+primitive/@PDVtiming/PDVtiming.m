% This class...

%
%
%
classdef PDVtiming < handle
    properties
        Experiment = 'Z????' % Experiment label
    end
    properties (SetAccess=protected)
        Comment = '' % Experiment comments
        Probe % Probe numbers
        ProbeDelay % Probe delays
        Diagnostic % Diagnostic channel number
        DiagnosticDelay % Diagnostic delays
        Digitizer % Digitizer numbers
        DigitizerDelay % Digititizer output trigger delays
        DigitizerChannel % Digitizer channel numbers
        DigitizerChannelDelay % Digitizer channel delays (relative)
        DigitizerTrigger % Digitizer trigger times
        MeasurementConnection = [] % Measurement connections
        MeasurementLabel = {} % Measurment label
    end
    properties
        MaxConnections = 0 % Maximum number of measurement connections
        DigitizerScaling % Digitizer time scaling [s -> ns]
        DerivativeSmoothing  % Derivative smoothing duration [ns]
        FiducialRange % Optical fiducial search range [ns]
        OBRwidth % OBR analysis width [ns]
        OBRreference % OBR reference times [ns]
    end
    properties (Access=protected,Hidden=true)
        DialogHandle
        SessionFile = ''
    end
    methods (Hidden=true)
        function object=PDVtiming(filename,mode)
            applyDefaults(object);
            % manage input
            if (nargin<1) || isempty(filename)
                % do nothing
            else
                loadSession(object,filename);
            end
            if (nargin<2) || isempty(mode)                
                mode='developer';
            end
            assert(ischar(mode),'ERROR: invalid mode');
            % process mode
            switch lower(mode)
                case 'gui'
                    runGUI(object);                
                otherwise
                    % do nothing
            end
        end
        varargout=applyDefaults(varargin);
        varargout=runGUI(varargin);
    end
    %%
    methods (Access=protected,Hidden=true)
        varargout=loadSession(varargin);
    end
    %% hide class methods from casual users
    methods (Hidden=true)
        %varargout=addlistener(varargin);
        varagout=eq(varargin);
        varargout=findobj(varargin);
        varargout=findprop(varargin);
        varagout=ge(varargin);
        varagout=gt(varargin);
        %varagout=isvalid(varargin);
        varagout=le(varargin);
        varagout=lt(varargin);
        varagout=ne(varargin);
        varagout=notify(varargin);
    end
    %% setters
    methods
        function set.Experiment(object,value)
            assert(ischar(value),'ERROR: invalid Experiment value');
            object.Experiment=value;
        end
        function set.MaxConnections(object,value)
            assert(SMASH.General.testNumber(value,'integer','positive','notzero'),...
                'ERROR: invalid number of maximum connections');
            object.MaxConnections=value;
        end
        function set.DigitizerScaling(object,value)
            test=SMASH.General.testNumber(value,'positive','notzero');
            assert(test,'ERROR: invalid digitizer scaling value');
            object.DigitizerScaling=value;
        end
        function set.DerivativeSmoothing(object,value)
            test=SMASH.General.testNumber(value,'positive','notzero');
            assert(test,'ERROR: invalid deritivate smoothing value');
            object.DerivativeSmoothing=value;
        end
        function set.OBRwidth(object,value)
            test=SMASH.General.testNumber(value,'positive','notzero');
            assert(test,'ERROR: invalid OBR width width');
            object.OBRwidth=value;
        end
    end
end