% density1 Probability density estimate for one-dimensional data
%
% This function estimates the probability density function for a set of
% one-dimensional data.  Several types of density estimate are supported,
% but for each case the function returns two outputs.
%    [weight,grid]=density1(...);
% The output "weight" approximates probability density at discrete
% locations ("grid").  If no outputs are used, results are plotted to the
% current MATLAB axes; these plots will look similar to a normalzied
% histogram (using a line instead of bars).
%
% The most basic density estimate uses binning.  Values in an array "data"
% can be automatically sorted in a fixed number of bins.
%    [...]=density1('bin',data);   % 10 grid points (default)
%    [...]=density1('bin',data,N); % N grid points
% Grids can also be specified manually:
%    [...]=density1('bin',value,grid);
% using an array of increasing, uniformly spaced set of numbers. 
%
% Density can also be estimated by direct summation of Gaussian kernels. In
% this approach, each data value is represented as a distribution of
% weights on the grid.  Grid options are the same as above:
%    [...]=density1('direct',data);  % 10 grid points (default)
%    [...]=density1('direct',data,N); % N grid points (default)
%    [...]=density1('direct',data,grid); % custom grid
% In these examples, the kernel width (standard deviation) is determined
% automatically.  Kernel width (common to all values) can be explicitly
% specied as well.
%    [...]=density1('direct',data,grid,width);
% NOTE: Direct summation can be very slow for large data sets or finely
% spaced grids.
%
% A faster implementation of the Gaussian kernel approach is available
% through Fast Fourier transforms.
%    [...]=density1('fft',...);
% The 'fft' approach supports the same input options as 'direct'.
% Local differences between the direct and FFT aproach are less than 0.1%.
%

%
% created January 6, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=density1(method,data,grid,width)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

if isempty(method)
    method='bin';
end
assert(ischar(method),'ERROR: invalid method');
method=lower(method);

assert(isnumeric(data) && ismatrix(data) && any(size(data)==1),...
    'ERROR: invalid data');
data=data(:);
Ndata=numel(data);

if (nargin<3) || isempty(grid)
    grid=10;
end
assert(isnumeric(grid),'ERROR: invalid grid');

if (nargin<4) || isempty(width)
    width=std(data)*Ndata^(-1/5); % Silverman's rule
end
assert(isnumeric(width) && isscalar(width),...
    'ERROR: invalid width data');

% generate grid as needed
if isscalar(grid)
    assert((grid>1) && (grid==round(grid)),...
        'ERROR: invalid number of grid points');    
    gap=5*width;
    start=min(data)-gap;
    stop=max(data)+gap;
    grid=linspace(start,stop,grid);    
end

Ngrid=numel(grid);
if strcmpi(method,'fft')
    N2=pow2(nextpow2(Ngrid));
    if Ngrid<N2
        fprintf('Grid changed from %d to %d points for FFT\n',Ngrid,N2);
        Ngrid=N2;
        grid=linspace(grid(1),grid(end),Ngrid);       
    end
end
dx=(grid(end)-grid(1))/(Ngrid-1);
grid=grid(:);

% calculate density as requested
switch method
    case 'bin'       
        data=round(data(:)/dx-grid(1)/dx)+1;
        data(data<1)=1;
        data(data>Ngrid)=Ngrid;        
        weight=accumarray(data,1,[Ngrid 1]);
    case 'direct'
        weight=zeros(size(grid));
        L=2*width^2;
        if SMASH.System.isParallel();
            parfor m=1:Ndata
                weight=weight+exp(-(grid-data(m)).^2/L);
            end
        else
            for m=1:Ndata
                weight=weight+exp(-(grid-data(m)).^2/L);
            end
        end
    case 'fft'
        start=-N2/2;
        stop=N2/2-1;
        k=(start:stop)/(N2*dx);
        k=ifftshift(k);  
        k=k(:);
        Q=SMASH.MonteCarlo.density1('bin',data,grid,width);
        Q=fft(Q);        
        P=exp(-2*pi^2*width^2*k.^2).*Q;
        weight=ifft(P,'symmetric');
        weight(weight<0)=0;
    otherwise
        error('ERROR: invalid method');
end

% normalize density
weight=weight/trapz(grid,weight);

% manage output
if nargout==0
    plot(grid,weight);
else
    varargout{1}=weight;
    varargout{2}=grid;
end

end
