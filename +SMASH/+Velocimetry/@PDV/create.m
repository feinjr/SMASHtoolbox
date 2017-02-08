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

% % determine sample rate
% t=object.STFT.Measurement.Grid;
% dt=(max(t)-min(t))/(numel(t)-1);
% object.SampleInterval=dt;
% object.SampleRate=1/dt;

% default settings
object.GraphicOptions=SMASH.Graphics.GraphicOptions;
object.GraphicOptions.Title='PDV measurement';
object.GraphicOptions.Marker='none';

object.NumberFrequencies=1000;
object.RemoveDC=true;
object.Window='hann';
object=partition(object,'block',1000);

end