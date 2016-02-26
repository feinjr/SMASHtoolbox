%
% value=lookup(object,'original',coordinate);
% value=lookup(object,'final',coordinate);

function value=lookup(object,mode,table)

% manage input
assert(nargin==3,'ERROR: insufficient input');

assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case {'xy' 'original' 'uv' 'final'}
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
    case {'xy' 'original'}
        table=table*object.Matrix.Forward;
end

% perform lookup 
value=object.Final.Lookup(table(:,1),table(:,2));

index=isnan(value);
value(index)=1/(2*pi*prod(object.Final.Std))*exp(...
    -(table(:,1)-object.Final.Mean(1)).^2/(2*object.Final.Var(1))...
    -(table(:,2)-object.Final.Mean(2)).^2/(2*object.Final.Var(2))...
    );

index=(value < object.Setting.DensityThreshold);
value(index)=object.Setting.DensityThreshold;
switch mode
    case {'xy' 'original'}
        value=value*object.Jacobian;
end

end