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

%% perform analysis
param.RMSnoise=object.RMSnoise;

t=object.STFT.Measurement.Grid;
param.SampleInterval=abs(t(end)-t(1))/(numel(t)-1);

data=object.STFT;
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

end