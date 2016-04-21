% BANDPASS Bandpass filtering of Image data 
%
% Usage:
%   >> object=bandpass(object,range,type,[order],[spectra]);
% "range" are normalized low & high frequency cutoffs (0<value<1), 
% e.g. [0.001 0.25];
% "type" is for the following filters:
%   'ideal', 'gaussian', 'butterworth', 'chebyshev'; 
% "order" is an integer>=1 used for 'butterworth' & 'chebyshev' filters    
% "spectra" is to used to show power spectra:
%   'on' or 'off' (default)
% 
% See also IMAGE

% created July 24, 2014 by Tommy Ao (Sandia National Laboratories)
% updated April 21, 2016 by Tommy Ao

%
function object=bandpass(object,varargin)

% handle input
assert(nargin>=3,'ERROR: bandpass range and type are required');
if isnumeric(varargin{1}) && (numel(varargin{1})==2)  
    range=varargin{1};
    assert(range(2)>range(1),'ERROR: high frequency cutoff must greater than low frequency cutoff');
else
    error('ERROR: input bandpass range: [range(1) range(2)]');
end
if ischar(varargin{2})
    type=varargin{2};
else
    error('ERROR: input bandpass type: ideal, gaussian, butterworth');
end
if nargin>3 && ~isempty(varargin{3}) && isnumeric(varargin{3}) 
    order=varargin{3};
else
    order=1;
end
if nargin>4 && ~isempty(varargin{4}) && ischar(varargin{4}) 
    spectra=varargin{4};
else
    spectra='off';
end

% verify uniform grid
object=makeGridUniform(object);

% find zeropadding size
m = max(size(object.Data)); % maximum dimension of data
P = 2^nextpow2(2*m); % find power-of-2 at least twice m

% calculate bandpassed data
BFdata=calculate_bandpass(object.Data,P,range,type,order,spectra);

% create bandpassed Image object
object.Data=BFdata(1:length(object.Grid2),1:length(object.Grid1));
object.DataLabel='Intensity (a.u.)';
object=updateHistory(object);

% show bandpassed Image object
% view(object);
% title(strcat((object.GraphicOptions.Title),' - bandpassed'));

end

function BFdata=calculate_bandpass(objectData,P,range,type,order,spectra)

% FFT bandpass type
[B,H1,H2]=bandpasstype(P,range,type,order);

% FFT data
F=fft2(double(objectData),H1,H2);

% apply bandpass to data
BF = B.*F;

% inverse FFT bandpassed data
BFdata=real(ifft2(BF)); 
BFdata=BFdata-min(min(BFdata));

if strcmpi(spectra,'on')
    % plot power spectra
    figure;
    subplot(2,2,1); 
    imagesc(fftshift(log(abs(F)))); caxis([0 max(max(log(abs(F))))]);
    title('Power spectrum of data');
    subplot(2,2,2);
    imagesc(fftshift(B)); caxis([min(min(abs(B))) max(max(abs(B)))]);
    title('Power spectrum of bandpass');
    subplot(2,2,3);
    imagesc(fftshift(log(abs(BF)))); caxis([0 max(max(log(abs(BF))))]);
    title('Power spectrum of bandpassed data');
    set(gcf,'OuterPosition',[0 300 800 800]);
end

end


function [B,H1,H2]=bandpasstype(P,range,type,order)

% set up the meshgrid arrays needed for computing the required distances
PQ = [P, P];

% set bandpass range
D0H = round(range(1)*sqrt((PQ(1)^2+PQ(2)^2))/2); % highpass cutoff
D0L = round(range(2)*sqrt((PQ(1)^2+PQ(2)^2))/2); % lowpass cutoff

u = 0:(PQ(1)-1);
v = 0:(PQ(2)-1);
idx = find(u > PQ(1)/2); % compute the indices for use in meshgrid
u(idx) = u(idx) - PQ(1);
idy = find(v > PQ(2)/2);
v(idy) = v(idy) - PQ(2);
[V, U] = meshgrid(v, u); % compute the meshgrid arrays
D = sqrt(U.^2 + V.^2); % compute the distances D(U, V)

% calculate bandpass type
switch lower(type)
    case 'ideal'
        L = double(D <=D0L);
        H = 1 - double(D <=D0H);
        B = H.*L;
    case 'gaussian'
        L = exp(-(D.^2)./(2*(D0L^2)));
        H = 1 - exp(-(D.^2)./(2*(D0H^2)));
        B = H.*L;
    case 'butterworth'
        n = order;
        L = 1./(1 + (D./D0L).^(2*n));
        H = 1 - 1./(1 + (D./D0H).^(2*n));
        B = H.*L;
 %       B = 1./(1 +((D.^2-D0L.*D0H)./D./(D0H-D0L)).^(2*n));
    case 'chebyshev'
        n = order;
        epsilon = 1;
        TL = polyval(ChebyshevPoly(n),D./D0L);
        L = 1./(1 + epsilon^2.*TL.^2);
        TH = polyval(ChebyshevPoly(n),D./D0H);
        H = 1 - 1./(1 + epsilon^2.*TH.^2);
        B = H.*L;
    otherwise
        error('Error: invalid bandpass choice');
end

H1=size(H,1);
H2=size(H,2);

end
