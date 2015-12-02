% analyzeTiming Diagnostic timing analysis
%
% UNDER CONSTRUCTION...

%
%
%
function analyzeTiming(diagnostic,filename)

% manage input
assert(nargin>=1,'ERROR: no diagnostic specified');
assert(ischar(diagnostic),'ERROR: invalid diagnostic');
diagnostic=lower(diagnostic);

if (nargin<2) || isempty(filename)
    filename='';
end

% 
switch diagnostic
    case 'pdv'
        object=SMASH.Z.PDVtiming(filename);
    otherwise
        error('ERROR: invalid diagnostic');
end

setup(object);