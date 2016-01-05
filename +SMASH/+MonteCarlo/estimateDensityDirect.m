function varargout=estimateDensityDirect(table,width,Ngrid)

% manage input
assert(nargin>0,'ERROR: insufficient input');
assert(isnumeric(table) && ismatrix(table) && ~isempty(table),...
    'ERROR: invalid data table');
[Ndata,Ndim]=size(table);

if (nargin<2) || isempty(width)
    width=std(table)*Ndata^(-1/5); % Silverman's rule
    %fprintf('Using Silverman''s rule for kernel width:\n');
    %fprintf('\t');
    %fprintf('%#.3g ',width);
    %fprintf('\n');
end
assert(isnumeric(width) && numel(width)==Ndim,...
    'ERROR: invalid width value');

if (nargin<3) || isempty(Ngrid)
    Ngrid=1000;
end
if isscalar(Ngrid)
    Ngrid=repmat(Ngrid,[1 Ndim]);
end
assert(isnumeric(Ngrid) && numel(Ngrid)==Ndim,...
    'ERROR: invalid number of grid points');

% perform density estimate
switch Ndim
    case 1
        [grid,data]=density1(table,width,[Ndata Ngrid]);
    otherwise
        error('ERROR: %d-dimensional data not currently supported',Ndim);
end

% manage output
if nargout==0
    switch Ndim
        case 1
            plot(grid,data);
    end
else
    varargout{1}=grid;
    varargout{2}=data;
end

end

function [grid,data]=density1(table,width,Npoints)

% generate grid
gap=5*width;
start=min(table)-gap;
stop=max(table)+gap;
N2=pow2(nextpow2(Npoints(2)));
grid=linspace(start,stop,N2);

% calculate density
data=zeros(size(grid));
L=2*width^2;
for m=1:Npoints(1)
%parfor m=1:Npoints(1)
    data=data+exp(-(grid-table(m)).^2/L);
end

% normalize density
data=data/trapz(grid,data);

end