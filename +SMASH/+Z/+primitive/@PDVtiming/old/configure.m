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
           
        case 'measurement'
       
          
        case 'connections'
            assert(isnumeric(value) && ismatrix(value),...
                'ERROR: invalid Connection value');
            object.ConnectionTable=value;
        case 'digitizerscaling'
            
        case 'smoothduration'
              
        otherwise
            error('ERROR: invalid property name');
    end
end

end