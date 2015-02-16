% 
%     >> object=PDV(time,signal); % numeric input
%     >> object=PDV(filename,format,record); % load from file
%     >> object=PDV(source); % load source (Signal/STFT) object
classdef PDV
    %%
    properties
        Measurement % STFT object
    end
    properties (SetAccess=protected)
        Preview % Preview Image object
        Boundary = {} %  BoundaryCurveGroup object
    end  
    %%
    methods (Hidden=true)
        function object=PDV(varargin)
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
        function object=set.Measurement(object,value)
            assert(isa(value,'SMASH.SignalAnalysis.STFT'),...
                'ERROR: invalid Measurement setting')
            object.Measurement=value;
        end
    end
end