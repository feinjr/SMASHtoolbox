% density2 Probability density estimate for two-dimensional data
% UNDER CONSTRUCTION...
%
%    [...]=density2(data,name,value,...);
%    'Calculation': 'fft', 'bin', 'direct'
%    'GridPoints': 1-2 integer values
%    'Smoothing': scalar >0
%    'Result': 'full', 'bound'

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
function varargout=density2(method,data,Ngrid,smooth)
% function varargout=density2(data,varargin)

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
assert(isnumeric(Ngrid) && any(numel(Ngrid)==[1 2]) && ...
    (all(Ngrid>1)) && (all(Ngrid==round(Ngrid))),...
    'ERROR: invalid number of grid points');
if isscalar(Ngrid)
    Ngrid=repmat(Ngrid,[1 2]);
else
    Ngrid=reshape(Ngrid,[1 2]);
end
if strcmpi(method,'fft')
    N2=pow2(nextpow2(Ngrid));
    if any(Ngrid<N2)
        fprintf('Increasing number of grid points for FFT calculation\n');
        Ngrid(2,:)=N2;
        Ngrid=max(Ngrid,[],1);
    end
end

if (nargin<4) || isempty(smooth)
    smooth=1;
end
assert(isnumeric(smooth) && any(numel(smooth)==[1 2]) && all(smooth>0),...
    'ERROR: invalid smoothing factor');
if isscalar(smooth)
    smooth=repmat(smooth,[1 2]);
end

% SVD reduction
center=mean(data,1);
data=bsxfun(@minus,data,center);

[data,S,V]=svd(data,0);
Sinv=zeros(2,2);
Sinv([1 4])=1./S([1 4]);
Vinv=V';
width=smooth.*KernelWidth(data);

% generate normalized grid
sigma=std(data,[],1);
bound=5*sigma.*smooth;
g1=linspace(-bound(1),+bound(1),Ngrid(1));
dg(1)=(g1(end)-g1(1))/(Ngrid(1)-1);
g2=linspace(-bound(2),+bound(2),Ngrid(2));
dg(2)=(g2(end)-g2(1))/(Ngrid(2)-1);
g2=g2(:);

% calculate density as requested
switch method
    case {'bin' 'fft'}
        table=nan(Ndata,2);
        table(:,1)=round(data(:,1)/dg(1)-g1(1)/dg(1))+1;
        table(:,2)=round(data(:,2)/dg(2)-g1(1)/dg(2))+1;
        table(table<1)=1;
        table((table(:,1)>=Ngrid(1)),1)=Ngrid(1);
        table((table(:,2)>=Ngrid(2)),2)=Ngrid(2);
        result=accumarray(table,1,Ngrid);
        Q=transpose(result);
end

[g1,g2]=meshgrid(g1,g2);
switch method
    case 'bin'
        weight=Q;
    case 'direct'
        weight=zeros(Ngrid(2),Ngrid(1));
        L=2*width.^2;
        if SMASH.System.isParallel();
            parfor m=1:Ndata
                temp=(g1-data(m,1)).^2/L(1)+(g2-data(m,2)).^2/L(2); %#ok<PFBNS>
                weight=weight+exp(-temp);
            end
        else
            for m=1:Ndata
                temp=(g1-data(m,1)).^2/L(1)+(g2-data(m,2)).^2/L(2);
                weight=weight+exp(-temp);
            end
        end
    case 'fft'
        start=-Ngrid(1)/2;
        stop=Ngrid(1)/2-1;
        k1=(start:stop)/(Ngrid(1)*dg(1));
        k1=ifftshift(k1);
        start=-Ngrid(2)/2;
        stop=Ngrid(2)/2-1;
        k2=(start:stop)/(Ngrid(2)*dg(2));
        k2=ifftshift(k2);
        [k1,k2]=meshgrid(k1,k2);       
        Q=fft2(Q);
        P=exp(-2*pi^2*width(1)^2*k1.^2).*exp(-2*pi^2*width(2)^2*k2.^2).*Q;
        weight=ifft2(P,'symmetric');
        weight(weight<0)=0;
end

% map normalized grid to original coordinates
temp=[g1(:) g2(:)];
temp=temp*S*Vinv;
temp=bsxfun(@plus,temp,center);

grid1=linspace(min(temp(:,1)),max(temp(:,1)),Ngrid(1));
grid2=linspace(min(temp(:,2)),max(temp(:,2)),Ngrid(2));
[grid1,grid2]=meshgrid(grid1,grid2);

temp=[grid1(:) grid2(:)];
temp=temp*Vinv*Sinv;
h1=reshape(temp(:,1),size(weight));
h2=reshape(temp(:,2),size(weight));
weight=interp2(g1,g2,weight,h1,h2);
weight(isnan(weight))=0;

grid1=grid1(1,:);
grid2=grid2(:,1);

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