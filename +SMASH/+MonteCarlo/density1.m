% density1 Probability density estimate for one-dimensional data
%
% This function estimates the underlying probability density for a
% one-dimensional data set.  Several types of density estimate are
% supported, but in each case the function returns two outputs.
%    [weight,grid]=density1(...);
% The output "weight" approximates probability density at discrete
% locations ("grid").  When no outputs are specified, the normalized
% density is plotted in the current MATLAB axes.
%
% Basic density estimatation uses binning: data values are sorted into
% uniform bins centered on N grid points.
%    [...]=density1('bin',data,N); % N=10 by default
% Density can also be estimated by direct summation of Gaussian kernels. In
% this approach, each data value is represented as a distribution of
% weights on the grid.
%    [...]=density1('direct',data,N); % N=100 by default
% Kernel width (standard deviation) is determined automatically but can be
% modified through a smoothing factor.
%    [...]=density1('direct',data,N,smooth); % smooth > 0
% The default smoothing factor is 1: larger values reduce local variations,
% possibly obscuring real features.
% NOTE: Direct summation can be *very* slow for large data sets or finely
% spaced grids.
%
% A faster implementation of the Gaussian kernel approach is available
% through Fast Fourier transforms.
%    [...]=density1('fft',data,N,smooth); % N=128 by default
% The 'fft' approach supports the same input options as 'direct'; the
% number of grid points is rounded to the next power of two as needed.
% Local differences between the direct and FFT aproach are about 0.1% or
% less (RMS) for adequately sampled grids.
%
% See also MonteCarlo, density2
%

%
% created January 6, 2016 by Daniel Dolan (Sandia National Laboratories)
% revised Februay 9, 2016 by Daniel Dolan
%    -changed to SVD approach for consistency with density
%    -updated documentation
%
function varargout=density1(method,data,Ngrid,smooth)

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

if (nargin<3) || isempty(Ngrid)
    switch method
        case 'bin'
            Ngrid=10;
        case 'direct'
            Ngrid=100;
        otherwise
            Ngrid=128;           
    end   
end
assert(isnumeric(Ngrid) && isscalar(Ngrid) && (Ngrid>1) && (Ngrid==round(Ngrid)),...
    'ERROR: invalid number of grid points');
if strcmpi(method,'fft')
    N2=pow2(nextpow2(Ngrid));
    if Ngrid<N2
        fprintf('Grid changed from %d to %d points for FFT\n',Ngrid,N2);
        Ngrid=N2;      
    end
end

if (nargin<4) || isempty(smooth)
    smooth=1;
end
assert(isnumeric(smooth) && isscalar(smooth) && (smooth>0),...
    'ERROR: invalid smoothing factor');

% SVD reduction
center=mean(data,1);
data=bsxfun(@minus,data,center);

[data,S,V]=svd(data,0);
VT=V';
width=smooth*KernelWidth(data);

% generate grid
sigma=std(data);
grid=linspace(-5*sigma,+5*sigma,Ngrid);

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
        weight=zeros(Ngrid,1);
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
        start=-Ngrid/2;
        stop=Ngrid/2-1;
        k=(start:stop)/(Ngrid*dx);
        k=ifftshift(k);  
        k=k(:);
        Q=SMASH.MonteCarlo.density1('bin',data,Ngrid);
        Q=fft(Q);        
        P=exp(-2*pi^2*width^2*k.^2).*Q;
        weight=ifft(P,'symmetric');
        weight(weight<0)=0;
    otherwise
        error('ERROR: invalid method');
end

% map results to original coordinate
grid=grid*S*VT+center;

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
