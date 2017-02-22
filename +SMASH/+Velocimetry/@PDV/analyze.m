% analyze Perform history analysis
% 
% This method analyzes...
%
% object=analyze(object,'power');
% object=analyze(object,'power',mode); % 'centroid'
%


% object=analyze(object,'sinusoid');
% object=analyze(object,'sinusoid',name,value,...)
% Valid names:
%   'UniqueTolerance'
%   'ElectricalHarmonics' 
%   'OpticalHarmonics'
%
% 



%
% See also PDV, bound, convert, partition
%

%
% Created March 2, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=analyze(object,mode,varargin)

%% manage input
if (nargin<2) || isempty(mode)
    mode='power';
end
assert(ischar(mode),'ERROR: invalid analysis mode');
mode=lower(mode);

%% update partitioning
object=partition(object,'Points',[object.STFT.Partition.Points object.STFT.Partition.Skip]);

%% manage boundaries and limits
boundary=object.Boundary;
if isempty(boundary)
    [xlimit,~]=limit(object.STFT.Measurement);
    M=numel(xlimit);
    xlimit=sort([xlimit(1) xlimit(end)]);
    SampleTime=abs(diff(xlimit))/(M-1);
    NyquistFrequency=1/(2*SampleTime);
    %
    table=nan(2,3);    
    table(1,:)=[xlimit(1) NyquistFrequency/2 NyquistFrequency/2];
    table(2,:)=[xlimit(2) NyquistFrequency/2 NyquistFrequency/2];
    boundary=SMASH.ROI.BoundingCurve('horizontal',table);
    boundary.Label='Default boundary';
    boundary={boundary};
end

Nboundary=numel(boundary);
start=nan(Nboundary,1);
stop=start;
for n=1:Nboundary
    temp=boundary{n}.Data([1 end],1);   
    temp=sort(temp);
    start(n)=temp(1);
    stop(n)=temp(2);
end
start=min(start);
stop=max(stop);

data=object.STFT;
data.Measurement=crop(data.Measurement,[start stop]);

%% perform analysis
param.RMSnoise=object.RMSnoise;

t=object.STFT.Measurement.Grid;
param.SampleInterval=abs(t(end)-t(1))/(numel(t)-1);

switch lower(mode)
    case 'power'
        object.Frequency=analyzeSpectrum(data,boundary,...
            param,varargin{:});
    case 'sinusoid'
        error('ERROR: sinusoid analysis is not ready yet');
        %object.RawOutput=analyzeSinusoid(measurement,boundary,...
        %    setting,varargin{:});
    otherwise
        error('ERROR: %s is not a valid analysis mode',mode);
end

object.Velocity={}; 

end