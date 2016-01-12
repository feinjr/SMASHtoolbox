%
%

%
% created December 9, 2015 by Patrick Knapp (Sandia National Laboratories)
%
classdef NeutronSpectrum
    %%
    properties
        Measurement % nTOF measurement (SignalGroup object)
    end
    properties (SetAccess=protected)
        Settings % Analysis settings (structure)d
    end
    %%
    methods (Hidden=true)
        function object=NeutronSpectrum(varargin)
            
            % default settings
            p=struct();
            p.Model='Ballabio';
            p.ModelParameters = struct('Ti',3);
            object.Settings=p;
            
            % manage input
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=SMASH.SignalAnalysis.Signal(varargin{1});
                object.Measurement=varargin{1};
            elseif (nargin>0) && ischar(varargin{1})
                temp=SMASH.FileAccess.readFile(varargin{:});
                switch class(temp)
                    case 'SMASH.SignalAnalysis.SignalGroup'
                        object=temp;
                    case 'SMASH.SignalAnalysis.Signal'
                        object=temp;
                    otherwise
                        object.Measurement=SMASH.SignalAnalysis.SignalGroup(varargin{:});
                end
                object.Measurement = temp;
            else
                object.Measurement=SMASH.SignalAnalysis.SignalGroup(varargin{:});
            end
            object.Measurement.Name='nTOF measurement';
            object.Measurement.GraphicOptions.Title='nTOF measurement';
            object.Settings=p;
            
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
            assert(isa(value,'SMASH.SignalAnalysis.SignalGroup') || isa(value,'SMASH.SignalAnalysis.Signal'),...
                'ERROR: Measurement property must be a Signal or SignalGroup object');
            object.Measurement=value;
        end
    end
end
