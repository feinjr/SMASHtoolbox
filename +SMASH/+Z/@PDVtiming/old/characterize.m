function characterize(object,quantity,index,varargin)

% manage input
assert(nargin>=3,'ERROR: insufficient input');

assert(isnumeric(index) && isscalar(index),'ERROR: invalid index');

%
switch lower(quantity)
    case 'probedelay'
        asssert(any(index==object.Probe),'ERROR: invalid probe index');
        object.ProbeDelay(index)=characterizeProbe(varargin{:});
    case 'diagnosticdelay'
        assert(any(index==object.Diagnostic),...
            'ERROR: invalid diagnostic index');
        object.Diagnostic(index)=value;
    case 'digitizerdelay'
        assert(any(index==object.Digitizer),...
            'ERROR: invalid digitizer index');
        object.DigitizerDelay=value;
    case 'digitizertrigger'
        assert(any(index==object.Digitizer),...
            'ERROR: invalid digitizer index');        
        object.DigitizerTrigger=characterizeTrigger(index,varargin{:});
    otherwise
        error('ERROR: invalid characterization name');
end

end