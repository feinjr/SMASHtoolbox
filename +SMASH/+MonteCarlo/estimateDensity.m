% estimateDensity Estimate probability density
%
% This function estimates probability density from finite set of
% measurements.
% 
% UNDER CONSTRUCTION
%

%
% created January 4, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=estimateDensity(table,width,Ngrid)

% manage input
assert(nargin>0,'ERROR: insufficient input');
assert(isnumeric(table) && ismatrix(table) && ~isempty(table),...
    'ERROR: invalid data table');
[Ndata,Ndim]=size(table);

if (nargin<2) || isempty(width)
    width=std(table)*Ndata^(-1/5); % Silverman's rule   
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

% generate k and Q(k)
dx=(grid(end)-grid(1))/(N2-1);
start=-N2/2;
stop=N2/2-1;
k=(start:stop)/(N2*dx);
k=ifftshift(k);

Q=hist(table,grid);
Q=fft(Q);

% calculate P(k) and P(x)
P=exp(-2*pi^2*width^2*k.^2).*Q;
P=ifft(P,'symmetric');
P(P<0)=0;

% normalize P(x)
data=P/trapz(grid,P);

end