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
    properties %(SetAccess=protected)
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
            p.FitSignal = 1;            %   index telling which signal to use for fitting
            p.Fit = [];                 %   fit object containing bets fit
            object.Settings=p;
            
            % manage input
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=SMASH.SignalAnalysis.SignalGroup(varargin{1});
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
            elseif ( nargin>0 ) && isnumeric(varargin{1})  && ischar(varargin{2})
                fileName = strcat('pbfa2z_',num2str(varargin{1}),'.pff');
                switch varargin{2}
                    case {'25 m', '25m', 'LOS50'}
                        if varargin{1} < 2710
                            temp = GrabSignals(fileName,{'NTF05A01MSH ', 'NTF05B01MSH '});
                        else
                            temp = GrabSignals(fileName,{'NTF05A01MSH ', 'NTF05B01MSH ', 'NTF05C01MSH '});
                        end
                        p.Distance = 2510;
                        p.Location = 'LOS50, 25 m';
                        
                    case {'11 m', '11m','LOS270 rear'}
                        temp = GrabSignals(fileName,{'NTF27A01MSH ','NTF27B01MSH ','NTF27C01MSH '});
                        p.Distance = 1146;
                        p.Location = 'LOS270, 11 m';
                        
                    case {'9 m', '9m','LOS270 front'}
                        temp = GrabSignals(fileName,{'NTF27A02MSH ','NTF27B02MSH '});
                        p.Distance = 944;
                        p.Location = 'LOS270, 9 m';
                        
                    case {'7 m', '7m','Bottom front'}
                        temp = GrabSignals(fileName,{'NTFBTA01MSH ','NTFBTB01MSH '});
                        p.Distance = 689.6;
                        p.Location = 'Bottom, 7 m';
                        
                    case {'8 m', '8m','Bottom rear'}
                        temp = GrabSignals(fileName,{'NTFBTA02MSH ','NTFBTB02MSH ','NTFBTA03MSH ','NTFBTB03MSH ','NTFBTC03MSH '});
                        p.Distance = 786;
                        p.Location = 'Bottom, 8 m';
                        
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
        varargout=store(varargin);
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
                'ERROR: Measurement property must be a Signal or SignalGroup object');
            object.Settings=value;
        end
    end
end

function object = GrabSignals(fileName,detectors)
a = SMASH.FileAccess.probeFile(fileName,[]);

% find indeces of NTF signals
k = 0;
for i = 1:size(a,2)
    if strcmp(a(i).Title(1:3),'NTF')
        k = k+1;
        record = i;
    end
end
n = 0;
ntf = cell(size(detectors));
numsamples = zeros(size(detectors));
for i = (record-k+1):record
    switch a(i).Title
        case detectors
            n = n+1;
            d = SMASH.FileAccess.readFile(fileName,[],i);
            ntf{n} = SMASH.SignalAnalysis.Signal(d.X, d.Data);
            
            if n == length(detectors)
                for k = 1:length(detectors); numsamples(k) = length(ntf{k}.Grid); end
                [N,I] = max(numsamples);
                x = ntf{I}.Grid;
                Data = zeros(N,n);
                for j = 1:n; ntf{j} = regrid(ntf{j},x); Data(:,j) = ntf{j}.Data; end
                object = SMASH.SignalAnalysis.SignalGroup(ntf{1}.Grid,Data);
            end
    end
end

end