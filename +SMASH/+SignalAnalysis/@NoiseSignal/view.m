function varargout=view(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='measurement';
end
assert(ischar(mode),'ERROR: invalid view mode');

% generate plot
switch lower(mode)
    case 'measurement'
        hl=view(object.Measurement,varargin{:});      
    case 'spectrum'      
        [f,P]=fft(object.Measurement);                
        temp=SMASH.SignalAnalysis.Signal(f,P);
        temp.GridLabel='Frequency';
        temp.DataLabel='Power';
        hl=view(temp,varargin);        
    case 'autocorrelation'
        
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout>0
    varargout{1}=hl;
end

end