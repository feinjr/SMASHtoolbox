% analyze Perform history analysis
%
% This method performs PDV history analysis.
%    object=analyze(object);
% The current analysis mode is 'robust', which uses an interative centroid
% calculation.
% UNDER CONSTRUCTION

%
% Calling this method updates the Frequency and Amplitude properties and
% resets the Velocity property.  The Frequency property has at least one
% data set per boundary selection.  The second data set, which descibes
% uncertainty, is only generated if the RMSnoise property has been
% specified.
%
% See also PDV, bound, characterize,convert, partition
%

%
% Created March 6, 2017 by Daniel Dolan (Sandia National Laboratories)


% UNDER CONSTRUCTION
% object=analyze(object,'sinusoid');
% object=analyze(object,'sinusoid',name,value,...)
% Valid names:
%   'UniqueTolerance'
%   'ElectricalHarmonics' 
%   'OpticalHarmonics'
%
% 

function object=analyze(object,mode,varargin)

%% manage input
if (nargin<2) || isempty(mode)
    mode='robust';
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

%%
if object.NoiseCharacterized
    noise=object.NoiseSignal;
else
    noise=[];
end

%% perform analysis
switch lower(mode)
    case 'robust' 
        if nargin > 2
            warning('SMASH:PDV',...
                'Extra inputs are not passed in robust analysis');
        end
        [object.AnalysisResult,extra]=analyzeRobust(data,boundary,noise);
        object.STFT.FFToptions.NumberFrequencies=extra.NumberFrequencies;
    case 'power'        
        %object.Frequency=analyzeSpectrum(data,boundary,...
        %    param,varargin{:});
        error('ERROR: power analysis is not ready yet');
    case 'sinusoid'
        error('ERROR: sinusoid analysis is not ready yet');
        %object.RawOutput=analyzeSinusoid(measurement,boundary,...
        %    setting,varargin{:});
    otherwise
        error('ERROR: %s is not a valid analysis mode',mode);
end

object.Analyzed=true;

end