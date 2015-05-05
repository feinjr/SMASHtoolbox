% lookupConstant Look up physical constant
%
%     >> c0=lookupConstant('c0'); 
%
% UNDER CONSTRUCTION
%
% See also Reference
%

function varargout=lookupConstant(name,option)

% manage input
assert(ischar(name),'ERROR: invalid constant name');

if (nargin<2) || isempty(option)
    option='SI';
end
assert(ischar(option),'ERROR: invalid unit option');

% perform lookup
switch lower(name)
    case {'na','avogadro'} % spelling?
    case {'kb','boltzman'}
    case {'c0','speed of light'}
        name='c0';
        value(1)=299792458;
        value(2)=value(1)*1e2;
        units={'m/s' 'cm/s'};
    case 'g'
    case {'h','planck'}
        
    case 'hbar'


        
    case {'me','m_e','electron mass'}
        
    case 'proton mass'
        
    otherwise
        error('ERROR: constant name');
end

% apply option
switch lower(option)
    case 'si'
        value=value(1);
        units=units{1};
    case 'cgs'
        value=value(2);
        units=units{2};
    otherwise
        error('ERROR: invalid unit option');
end

% manage output
if nargout==0
    fprintf('%s = %g %s\n',name,value,unit);
else
    varargout{1}=value;
    varargout{2}=units;
end

end