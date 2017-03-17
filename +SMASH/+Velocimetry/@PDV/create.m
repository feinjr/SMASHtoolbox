function object=create(object,varargin)

% manage input
if (nargin==2) && isobject(varargin{1})
    switch class(varargin{1})
        case 'SMASH.SignalAnalysis.STFT'
            object.STFT=varargin{1};
        case 'SMASH.SignalAnalysis.Signal'
            object.STFT=SMASH.SignalAnalysis.STFT(varargin{1});
        otherwise
            error('ERROR: unable to create PDV object from this input');
    end        
else
    source=SMASH.SignalAnalysis.STFT(varargin{:});
    object.STFT=source;
end

object.NumberFrequencies=1000;
object.RemoveDC=true;
object.Window='hann';
object=partition(object,'block',1000);
object.STFT.FFToptions.Normalization='none';

object.NoiseSignal=SMASH.SignalAnalysis.NoiseSignal(1:16);

end