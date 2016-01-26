%
%

%
% created December 7, 2015 by Patrick Knapp (Sandia National Laboratories)
%
classdef NTOF
    %%
    properties
        Measurement % nTOF measurement (SignalGroup object)
    end
    properties (SetAccess=protected)
        Settings % Analysis settings (structure)d
    end
    %%
    methods (Hidden=true)
        function object=NTOF(varargin)
            
            % default settings
            p=struct();
            p.Distance=[];              %   Distance to detector in meters
            p.Location = [];            %   Detector location: '7 m','8 m','9 m', '11 m', '25 m'
            p.Bias = [];                %   Bias setting (under development)
            p.InstrumentResponse = [];  %   signal object containing IRF
            p.LightOutput = [];         %   signal object light output vs. energy, normalized to 2.45 MeV
            p.Shielding = [];           %   shielding configuration (under development)
            p.BangTime = [];            %   Bang time in seconds
            p.BurnWidth = [];           %   Burn width in seconds (estimate from x-rays)
            p.SignalLimits = [];        %   Limits of entire signal of interest
            p.NoiseLimits = [];         %   Limits to use for analyzing signal noise and baseline
            p.FitLimits = [];           %   Limits to use for fitting of signal
            p.FitSignal = [];           %   index telling which signal to use for fitting
            p.Fit = [];                 %   fit object containing bets fit
            p.Reaction = 'DDn';         %   Nuclear reaction to be modeled
            p.Earray = [1.5, 3, 500];   %   Emin, Emax and Num pts for calculating the neutron spectrum
            p.FinalSignal = [];         %   Signal object containing the final signal (baseline subtracted and cropped)
            
            object.Settings=p;
            
            % manage input
            % Pass object directly to NTOF
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=SMASH.SignalAnalysis.SignalGroup(varargin{1});
                object.Measurement=varargin{1};
            % Pass an sda file to NTOF
            elseif (nargin>0) && ischar(varargin{1})
                temp=SMASH.FileAccess.readFile(varargin{:});
                switch class(temp)
                    case 'SMASH.SignalAnalysis.SignalGroup'
                        object=temp;
                    case 'SMASH.SignalAnalysis.Signal'
                        object=temp;
                    otherwise
                end
            % Pass a shot number, and a detector ID, NTOF will create the
            % object from PFF file
            elseif ( nargin>0 ) && isnumeric(varargin{1})  && ischar(varargin{2})
                temp = SMASH.Z.ZSignals(varargin{1}, 'NTOF', '.pff',varargin{2});
                switch varargin{2}
                    case {'25 m', '25m', 'LOS50'}
                        p.Distance = 2510;
                        p.Location = 'LOS50, 25 m';
                        
                    case {'11 m', '11m','LOS270 rear'}
                        p.Distance = 1146;
                        p.Location = 'LOS270, 11 m';
                        
                    case {'9 m', '9m','LOS270 front'}
                        p.Distance = 944;
                        p.Location = 'LOS270, 9 m';
                        
                    case {'7 m', '7m','Bottom front'}
                        p.Distance = 689.6;
                        p.Location = 'Bottom, 7 m';
                        
                    case {'8 m', '8m','Bottom rear'}
                        p.Distance = 786;
                        p.Location = 'Bottom, 8 m';
                    case '8 m 1'
                        p.Distance = 786;
                        p.Location = 'Bottom, 8 m 1';
                    case '8 m 2'
                        p.Distance = 786;
                        p.Location = 'Bottom, 8 m 2';
                end
                object.Measurement = temp.Measurement;
            % Pass data directly to NTOF
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
        function object=set.Settings(object,value)
            assert(isstruct(value),...
                'ERROR: Settings must be a Structure');
            object.Settings=value;
        end
    end
end