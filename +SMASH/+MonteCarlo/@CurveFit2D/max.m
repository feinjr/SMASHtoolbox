% max Determine maximum density value/location
%
% line segments defined by a five-column table: [x0 y0 Lx Ly theta]
%

% ADD INDEX!!!e
function [value,location]=max(object,mode,table)

%% manage input
assert(nargin>=2,'ERROR: insufficient input');

assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case {'original' 'final'}
        % valid modes
    otherwise
        error('ERROR: invalid mode');
end

if (nargin<3)
    switch mode
        case 'original'
            location=object.Original.Mode;           
        case 'final'
            location=object.Final.Mode;
    end
    value=lookup(object,mode,location);
    return
end
assert(isnumeric(table) && ismatrix(table),...
    'ERROR: invalid segment table');
[rows,cols]=size(table);
assert(cols==2,'ERROR: invalid segment table');

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
value=inf;
location=nan(1,2);
for n=1:rows
    
end


% perform lookups as necessary
if ~object.AssumeNormal
    for n=1:rows
        % do something
    end
end

% scale results as necessary
switch mode
    case 'original'
        value=value*object.Matrix.Jacobian;
end

end

function segment=points2segments(point)

end