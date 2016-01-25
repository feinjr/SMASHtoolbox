%
%   This class is used to grab signals from ZDAS files and put them in a
%   signalgroup object.
%
%
%
% created January 25, 2016 by Patrick Knapp (Sandia National Laboratories)
%
classdef ZSignals
    %%
    properties
        Measurement % Z signal measurement (SignalGroup object)
    end
    %%
    methods (Hidden=true)
        function object=ZSignals(shot,varargin)
            % manage input
            if (nargin==1)
                % Need to prompt to choose a signal
            elseif ( nargin>2 ) && ischar(varargin{1})  && ischar(varargin{2})
                signal = varargin{1};
                format = varargin{2};
                if isempty(format); format = '.pff'; end
                switch signal
                    case 'NTOF'
                        assert(ischar(varargin{3}),...
                            'ERROR: Must specify from which detector to retrieve signals.')
                        signals = GrabNTFsignals(shot,varargin{3},format);
                    case 'PCD'
                        assert(ischar(varargin{3}),...
                            'ERROR: Must specify from which LOS to retrieve signals.')
                        signals = GrabPCDsignals(shot,varargin{3},format);
                    case 'Current'
                        signals = GrabCurrentsignals(shot,varargin{3},format);
                    case {'SiD', 'SID'}
                        assert(ischar(varargin{3}),...
                            'ERROR: Must specify from which LOS to retrieve signals.')
                        signals = GrabSiDsignals(shot,varargin{3},format);
                end
                object.Measurement = signals;
            end
            
        end
    end
end

