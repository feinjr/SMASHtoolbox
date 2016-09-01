function object=create(object,varargin)

% manage input
if (nargin==2) && isobject(varargin{1})
    switch class(varargin{1})
        case 'SMASH.SignalAnalysis.STFT'
            object.Measurement=varargin{1};
        case 'SMASH.SignalAnalysis.Signal'
            object.Measurement=SMASH.SignalAnalysis.STFT(varargin{1});
        otherwise
            error('ERROR: unable to create PDV object from this input');
    end        
else
    source=SMASH.SignalAnalysis.STFT(varargin{:});
    object.Measurement=source;
end

% determine sample rate
t=object.Measurement.Measurement.Grid;
dt=(max(t)-min(t))/(numel(t)-1);
object.SampleInterval=dt;
object.SampleRate=1/dt;

% default settings
object.GraphicOptions=SMASH.Graphics.GraphicOptions;
object.GraphicOptions.Title='PDV measurement';
object.GraphicOptions.Marker='none';

p=struct();
p.Wavelength=1550e-9;
p.ReferenceFrequency=0;
p.Bandwidth=nan;
p.RMSnoise=nan;

object.Settings=p;

end