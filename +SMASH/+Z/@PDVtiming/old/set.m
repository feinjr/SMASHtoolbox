% UNDER CONSTRUCTION
%


function set(object,name,index,value)

% manage input
assert(nargin==4,'ERROR: invalid number of inputs');

assert(isnumeric(index) && isscalar(index),'ERROR: invalid index');

assert(isnumeric(value),'ERROR: invalid time value');

%
switch lower(name)
    case 'probedelay'
        asssert(any(index==object.Probe),'ERROR: invalid probe index');
        object.ProbeDelay(index)=value;
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
        object.DigitizerTrigger=value;
    otherwise
        error('ERROR: invalid characterization name');
end

end