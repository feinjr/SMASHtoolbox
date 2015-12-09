function configure(object,varargin)

import SMASH.General.testNumber

% manage input
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid property name');
    value=varargin{n+1};
    switch lower(name)
        case 'experiment'
            assert(ischar(value,'ERROR: invalid Experiment value');
            object.Experiment=value;
        case 'measurement'
            assert(iscellstr(value),'ERROR: invalid Measurement value');
            object.Measurement=transpose(value(:));           
        case 'probe'
            assert(isnumeric(value),'ERROR: invalid Probe value');
            object.Probe=transpose(value(:));
        case 'diagnostic'
            assert(isnumeric(value),'ERROR: invalid Diagnostic value');
            object.Diagnostic=transpose(value(:));
        case 'digitizer'
            assert(isnumeric(value),'ERROR: invalid Digitizer value');
            object.Digitizer=transpose(value(:));            
        case 'connections'
            assert(isnumeric(value) && ismatrix(value),...
                'ERROR: invalid Connection value');
            object.ConnectionTable=value;
        case 'digitizerscaling'
            assert(testNumber(value,'positive','notzero'),...
                'ERROR: invalid digitizer scaling factor');
            object.DigitizerScaling=value;
        case 'smoothduration'
            assert(testNumber(value,'positive','notzero'),...
                'ERROR: invalid smoothing duration');
            object.SmoothDuration=value;        
        otherwise
            error('ERROR: invalid property name');
    end
end

end