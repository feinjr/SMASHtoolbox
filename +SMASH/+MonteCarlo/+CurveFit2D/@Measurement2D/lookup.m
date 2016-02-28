% lookup Look up density values
%
% This method looks up probability densities at locations specified in a
% two-column table.  Locations can be specified in original or final
% coordinates.
%    value=lookup(object,'original',[x y]);
%    value=lookup(object,'final',[u v]);
%
% See also Density2D
%

%
% created February 26, 2016 by Daniel Dolan (Sandia National Laboratories)
%

function value=lookup(object,mode,table)

% manage input
assert(nargin==3,'ERROR: insufficient input');

assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case {'original' 'final'}
        % valid modes
    otherwise
        error('ERROR: invalid mode');
end

assert(isnumeric(table) && ismatrix(table),...
    'ERROR: invalid coordinate table');
[~,cols]=size(table);
assert(cols==2,'ERROR: invalid coordinate table');

% transform coordinates as necessary
drop=any(isnan(table) | isinf(table),2);
table=table(~drop,:);

switch mode
    case 'original'
        table=table*object.Matrix.Forward;
end
u=table(:,1);
v=table(:,2);

% start with normal assumption
A=1/(2*pi*prod(object.Final.Std));
B=2*object.Final.Var;
u0=object.Final.Mean(1);
v0=object.Final.Mean(2);
value=A*exp(-(u-u0).^2/B(1)-(v-v0).^2/B(2));

% perform lookup 
if ~object.AssumeNormal
    ub=object.Final.ubound;
    vb=object.Final.vbound;
    index=(u>=ub(1)) & (u<=ub(2)) & (v>=vb(1)) & (v<=vb(2));
    value(index)=object.Final.Lookup(u(index),v(index));
end

% scale results as necessary
switch mode
    case 'original'
        value=value*object.Matrix.Jacobian;
end

end