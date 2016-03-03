% lookup Look up probability density
%
% This method looks up probability density at specified loctions.
%    value=lookup(object,'original',[x y]);
%    value=lookup(object,'scaled',[u v]);
%
% See also Density2D, findmax
%

%
% created March 3, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function value=lookup(object,mode,table,isnormal)

% manage input
assert(nargin>=3,'ERROR: insufficient input');

assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case {'original' 'scaled'}
        % valid modes
    otherwise
        error('ERROR: invalid mode');
end

assert(isnumeric(table) && ismatrix(table),...
    'ERROR: invalid coordinate table');
[~,cols]=size(table);
assert(cols==2,'ERROR: invalid coordinate table');

if (nargin<4) || isempty(isnormal) || strcmpi(isnormal,'general')
    isnormal=false;
elseif strcmpi(isnormal,'normal')
    isnormal=true;
end
assert(islogical(isnormal),'ERROR: invalid normal flag');

% transform coordinates as necessary
switch mode
    case 'original'
        table=bsxfun(@minus,table,object.Original.Mean);
        table=table*object.Matrix.Forward;
end
u=table(:,1);
v=table(:,2);

% start with normal assumption
A=1/(2*pi*prod(object.Scaled.Std));
B=2*object.Scaled.Var;
u0=object.Scaled.Mean(1);
v0=object.Scaled.Mean(2);
value=A*exp(-(u-u0).^2/B(1)-(v-v0).^2/B(2));

% perform lookup 
if ~isnormal
    ub=object.Scaled.ubound;
    vb=object.Scaled.vbound;
    index=(u>=ub(1)) & (u<=ub(2)) & (v>=vb(1)) & (v<=vb(2));
    value(index)=object.Scaled.Lookup(u(index),v(index));
end

% scale results as needed
switch mode
    case 'original'
        value=value*object.Matrix.Jacobian;
end

end