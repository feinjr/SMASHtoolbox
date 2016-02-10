% density2 Probability density estimate for two-dimensional data
%
% This function estimates the probability density function for a
% two-dimensional data set.  Several types of density estimate are
% supported, but for each case the function returns three outputs.
%    [weight,grid1,grid2]=density2(...);
% The output "weight" approximates probability density at discrete
% locations ("grid1" and "grid2").  If no outputs are used, results are plotted to the
% current MATLAB axes; these plots will look similar to a normalized
% histogram (image).
%
% The most basic density estimate uses binning.  Values in an array "data"
% can be automatically sorted in a fixed number of bins.
%    [...]=density2('bin',data);   % 16x16 grid points (default)
%    [...]=density2('bin',data,M,N); % M horizontal, N vertial grid points
% Grids can also be specified manually:
%    [...]=density2('bin',data,grid1,grid2);
% using an array of increasing, uniformly spaced set of numbers. 
%
% Density can also be estimated by direct summation of Gaussian kernels. In
% this approach, each data value is represented as a distribution of
% weights on the grid.  Grid options are the same as above:
%    [...]=density2('direct',data,...);
% By default, kernel widths (standard deviation) are determined
% automatically.  Kernel widths (common to all values) can be explicitly
% specied as well.
%    [...]=density2('direct',data,grid1,grid2,[width1 width2]);
% NOTE: Direct summation can be very slow for large data sets or finely
% spaced grids.
%
% A faster implementation of the Gaussian kernel approach is available
% through Fast Fourier transforms.
%    [...]=density2('fft',...);
% The 'fft' approach supports the same input options as 'direct'. Local
% differences between the direct and FFT aproach are about 0.1% or less
% (RMS) for adequately sampled grids
%

%
% created Feburary 8, 2016 by Daniel Dolan (Sandia National Lab
function varargout=density2(method,data,grid1,grid2,width)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

if isempty(method)
    method='bin';
end
assert(ischar(method),'ERROR: invalid method');
method=lower(method);

assert(isnumeric(data) && ismatrix(data) && any(size(data)==2),...
    'ERROR: invalid data');
if size(data,2) ~= 2
    data=transpose(data);
end
Ndata=size(data,1);

if (nargin<3) || isempty(grid1)
    grid1=16;
end
assert(isnumeric(grid1),'ERROR: invalid grid');

if (nargin<4) || isempty(grid2)
    grid2=16;
end
assert(isnumeric(grid2),'ERROR: invalid grid');

if (nargin<5) || isempty(width)
    temp=std(data,[],1);
    width(1)=temp(1)*Ndata^(-1/5); % Silverman's rule
    width(2)=temp(2)*Ndata^(-1/5); % Silverman's rule
end
if isscalar(width)
    width=repmat(width,[1 2]);
end
assert(isnumeric(width) && (numel(width)==2),...
    'ERROR: invalid width value');

% process grid1
if isscalar(grid1)
    assert((grid1>1) && (grid1==round(grid1)),...
        'ERROR: invalid number of grid points');    
    gap=5*width(1);
    start=min(data(:,1))-gap;
    stop=max(data(:,1))+gap;
    grid1=linspace(start,stop,grid1);    
end
Ngrid(1)=numel(grid1);

if strcmpi(method,'fft')
     N2=pow2(nextpow2(Ngrid(1)));
     if Ngrid(1)<N2
         fprintf('Grid1 changed from %d to %d points for FFT\n',Ngrid(1),N2);
         Ngrid(1)=N2;
         grid1=linspace(grid1(1),grid1(end),Ngrid(1));       
     end
end
dx(1)=(grid1(end)-grid1(1))/(Ngrid(1)-1);
grid1=reshape(grid1,[1 Ngrid(1)]);

% process grid2
if isscalar(grid2)
    assert((grid2>1) && (grid2==round(grid2)),...
        'ERROR: invalid number of grid points');    
    gap=5*width(2);
    start=min(data(:,2))-gap;
    stop=max(data(:,2))+gap;
    grid2=linspace(start,stop,grid2);    
end
Ngrid(2)=numel(grid2);

if strcmpi(method,'fft')
    N2=pow2(nextpow2(Ngrid(2)));
    if Ngrid(2)<N2
        fprintf('Grid changed from %d to %d points for FFT\n',Ngrid(2),N2);
        Ngrid(2)=N2;
        grid2=linspace(grid2(1),grid2(end),Ngrid(2));
    end
end
dx(2)=(grid2(end)-grid2(1))/(Ngrid(2)-1);
grid2=reshape(grid2,[Ngrid(2) 1]);

% calculate density as requested
switch method
    case 'bin'
        data(:,1)=round(data(:,1)/dx(1)-grid1(1)/dx(1))+1;
        data(:,2)=round(data(:,2)/dx(2)-grid2(1)/dx(2))+1;
        data(data<1)=1;        
        data((data(:,1)>Ngrid(1)),1)=Ngrid(1);
        data((data(:,2)>Ngrid(2)),1)=Ngrid(2);
        weight=accumarray(data,1,Ngrid);
        weight=transpose(weight);
    case 'direct'
        weight=zeros(Ngrid(2),Ngrid(1));
        [x,y]=meshgrid(grid1,grid2);        
        L=2*width.^2;
        if SMASH.System.isParallel();
            parfor m=1:Ndata
                temp=(x-data(m,1)).^2/L(1)+(y-data(m,2)).^2/L(2); %#ok<PFBNS>
                weight=weight+exp(-temp);
            end
        else
            for m=1:Ndata
                 temp=(x-data(m,1)).^2/L(1)+(y-data(m,2)).^2/L(2);
                 weight=weight+exp(-temp);
            end
        end
    case 'fft'
        start=-Ngrid(1)/2;
        stop=Ngrid(1)/2-1;
        k1=(start:stop)/(Ngrid(1)*dx(1));
        k1=ifftshift(k1);  
        start=-Ngrid(2)/2;
        stop=Ngrid(2)/2-1;
        k2=(start:stop)/(Ngrid(2)*dx(2));
        k2=ifftshift(k2);  
        [k1,k2]=meshgrid(k1,k2);
        Q=SMASH.MonteCarlo.density2('bin',data,grid1,grid2,width);
        Q=fft2(Q);        
        P=exp(-2*pi^2*width(1)^2*k1.^2).*exp(-2*pi^2*width(2)^2*k2.^2).*Q;
        weight=ifft2(P,'symmetric');
        weight(weight<0)=0;
end

% normalize density
temp=trapz(grid2,trapz(grid1,weight,2),1);
weight=weight/temp;

% manage output
if nargout==0
    imagesc(grid1,grid2,weight);
else
    varargout{1}=weight;
    varargout{2}=grid1;
    varargout{3}=grid2;
end

end