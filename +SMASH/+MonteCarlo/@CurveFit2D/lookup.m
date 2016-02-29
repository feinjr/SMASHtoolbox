% lookup Look up probability density for a specific measurement

%
% This method looks up probability density for a specific emasurement at
% specified loction.  Locations may be specified in original or scaled
% cooridnates using a two-column table.
%    value=lookup(object,index,'original',[x y]);
%    value=lookup(object,index,'scaled',[u v]);
%
%

%
% created February 26, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function value=lookup(object,index,mode,table)

% manage input
assert(nargin==4,'ERROR: insufficient input');

assert(isnumeric(index) && isscalar(index),...
    'ERROR: invalid measurement index');
valid=1:object.NumberMeasurements;
assert(any(index==valid),'ERROR: invalid measurement index');
result=object.MeasurementDensity{index};

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

% transform coordinates as necessary
switch mode
    case 'original'
        table=bsxfun(@minus,table,result.Original.Mean);
        table=table*result.Matrix.Forward;
end
u=table(:,1);
v=table(:,2);

% start with normal assumption
A=1/(2*pi*prod(result.Scaled.Std));
B=2*result.Scaled.Var;
u0=result.Scaled.Mean(1);
v0=result.Scaled.Mean(2);
value=A*exp(-(u-u0).^2/B(1)-(v-v0).^2/B(2));

% perform lookup 
if ~object.AssumeNormal || ~result.IsNormal
    ub=result.Scaled.ubound;
    vb=result.Scaled.vbound;
    index=(u>=ub(1)) & (u<=ub(2)) & (v>=vb(1)) & (v<=vb(2));
    value(index)=result.Scaled.Lookup(u(index),v(index));
end

% scale results as necessary
switch mode
    case 'original'
        value=value*result.Matrix.Jacobian;
end

end