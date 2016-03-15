% partition Set/view partition settings
%
% This method controls the partitioning of PDV objects.  Partitions can be
% specifed as a number of points, time durations, or a total number of
% blocks.  
%
% To partition a signal with a fixed number of points:
%     >> object=partition(object,'Points',points); % skip=points
%     >> object=partition(object,'Points',[points skip]);
% FFT calculations are performed over the specified number of points (zero
% padded to the next power of two).  The "skip" parameter determines the
% number of points between each FFT.
%
% FFT duration and advance settings can be specified in time units.
%     >> object=partition(object,'Duration',duration); % advance=duration
%     >> object=partition(object,'Duration',[duration advance]);
% Requests are converted to an integer number of samples, so actual
% durations and advances may be slightly different than requested.
%
% A fixed number of partitions can be also be specified.
%     >> object=partition(object,'Blocks',blocks); % overlap=0
%     >> object=partition(object,'Blocks',[blocks overlap]);
% The spacing between region centers is determined from the "blocks"
% parameter, i.e. this parameter (in conjuction with the total number of
% points) determines the "skip" parameter. By default, each region is
% distinct from its neighbors.  Fractional overlap between regions then
% defines the number of points in each region.
%     points=(overlap+1)*skip
%
% See also PDV, configure
%

%
% created March 2, 2015 by Daniel Dolan (Sandia National Laboratories)
% updated March 14, 2016 by Daniel Dolan
%   -domain scaling calculated whenever partitioning changes
%
function varargout=partition(object,varargin)

% manage input
if (nargout==0)
    if nargin>1
        warning('SMASH:PDV',...
            'Partition settings are ignored in display mode');
    end
    partition(object.Measurement);
    return;
end

% apply partition settings
object.Measurement=partition(object.Measurement,varargin{:});

% domain calibration
dt=object.SampleRate;

t=0:dt:object.Measurement.Partition.Duration;
fmin=1/t(end); % single fringe
fmax=1/(8*dt); % 1/4 of Nyquist
f0=(fmin+fmax)/2;
s=cos(2*pi*f0*t);
temp=SMASH.SignalAnalysis.Signal(t,s);
[f,P]=fft(temp,...
    'FrequencyDomain','positive',...
    'SpectrumType','power',...
    'NumberFrequencies',1e5);
Pmax=interp1(f,P,f0,'linear');
object.DomainScaling=Pmax;

% calculate minimum width
P=P/trapz(f,P);
width=sqrt(trapz(f,P.*(f-f0).^2));
object.MinimumWidth=width;
%object.MinimumWidth=1/(4*pi*t(end));

% manage output
if nargout>0
    varargout{1}=object;
end

end