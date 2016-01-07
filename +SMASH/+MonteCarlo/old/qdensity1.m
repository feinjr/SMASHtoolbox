% qdensity1 Kernel density estimate for 1D values
%
% This method calculates the kernel density estimate for a set of 1D
% values.  Each value is represented by a normal distribution of specified
% width on a uniformly spaced grid.
%    [grid,weight]=qdensity1(table,width,Ngrid);
% The default number of grid points is 1000.
% 
% NOTE: this function evaluates kernel density via the Fast Fourier
% transform.  It is usually much faster than direct evalution with modest
% accuracy loss (<0.1%).
%
% See also qdensity
%

%
% created January 6, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=qdensity1(table,width,Ngrid)

% manage input
assert(nargin>0,'ERROR: insufficient input');
assert(isnumeric(table) && ismatrix(table) && ~isempty(table),...
    'ERROR: invalid data table');
table=table(:);

[Ndata,Ndim]=size(table);

if (nargin<2) || isempty(width)
    width=std(table)*Ndata^(-1/5); % Silverman's rule   
end
assert(isnumeric(width) && numel(width)==Ndim,...
    'ERROR: invalid width value');
if width==0
    width=1;
end

if (nargin<3) || isempty(Ngrid)
    Ngrid=1000;
end
if isscalar(Ngrid)
    Ngrid=repmat(Ngrid,[1 Ndim]);
end
assert(isnumeric(Ngrid) && numel(Ngrid)==Ndim,...
    'ERROR: invalid number of grid points');

% perform density estimate
gap=5*width;
start=min(table)-gap;
stop=max(table)+gap;
N2=pow2(nextpow2(Ngrid));
grid=linspace(start,stop,N2);

% generate k and Q(k)
dx=(grid(end)-grid(1))/(N2-1);
start=-N2/2;
stop=N2/2-1;
k=(start:stop)/(N2*dx);
k=ifftshift(k);

%Q=hist(table,grid);
Q=SMASH.MonteCarlo.qhist1(table,grid);
Q=fft(Q);

% calculate P(k) and P(x)
P=exp(-2*pi^2*width^2*k.^2).*Q;
P=ifft(P,'symmetric');
P(P<0)=0;

% normalize P(x)
data=P/trapz(grid,P);

% manage output
if nargout==0
    plot(grid,data);
else
    varargout{1}=grid;
    varargout{2}=data;
end

end