% convert Convert raw output to frequency/velocity
%
% This method converts raw analysis output to frequency and velocity
% results.
%    object=convert(object);
% Conversion is automatically applied by the analyze mehtod and can be used
% anytime thereafter.  The reason for doing so is to apply setting changes
% (wavelength, reference frequency, RMS noise) *without* reanalyzing the
% measurement.
%
% See also PDV, analyze, characterize, configure
%

%
% created February 23, 2015 by Daniel Dolan (Sandia National Laboratories)
% revised March 17, 2016 by Daniel Dolan
%    -removed custom map function feature (should be part of leapfrog class)
%    -merged operations from the analyze method to clearly distinguish raw and processed results
function object=convert(object,varargin)

% make sure analysis has been performed
message={};
message{end+1}='ERROR: no analysis output for conversion';
message{end+1}='       Use "analyze" before calling this method';
assert(~isempty(object.RawOutput),'%s\n',message{:});

% conversion factors
fs=object.SampleRate;
tau=object.EffectiveDuration;
sigma=object.Settings.RMSnoise;
UncertaintyFactor=sqrt(6/fs/tau^3)*sigma/pi;

VelocityFactor=object.Settings.Wavelength/2;

% convert raw data
N=object.RawOutput.NumberSignals/4;
object.Frequency=cell(1,N);
object.Velocity=cell(1,N);
for n=1:N
    % select results for current boundary
    if n==1
        index=1:4; % center, amplitude, chirp, unique
    else
        index=index+4;
    end
    % generate name
    try
        name=object.Boundary{m}.Label;
    catch
        name='(no name)';
    end
    % remove NaN entries
    data=object.RawOutput.Data(:,index);
    keep=~isnan(data(:,1));
    data=data(keep,:);
    time=object.RawOutput.Grid(keep);
    % generate frequency results
    data(:,2)=UncertaintyFactor./data(:,2); % convert amplitude to uncertainty
    object.Frequency{n}=SMASH.SignalAnalysis.SignalGroup(time,data);
    object.Frequency{n}.GridLabel='Time';
    object.Frequency{n}.DataLabel='';
    object.Frequency{n}.Legend={'Value' 'Uncertainty' 'Chirp' 'Unique'};
    object.Frequency{n}.Name=name;
    % generate velocity results
    data(:,1)=VelocityFactor*(data(:,1)-object.Settings.ReferenceFrequency);
    data(:,2)=VelocityFactor*data(:,2);
    object.Velocity{n}=SMASH.SignalAnalysis.SignalGroup(time,data);
    object.Velocity{n}.GridLabel='Time';
    object.Velocity{n}.DataLabel='';
    object.Velocity{n}.Legend={'Value' 'Uncertainty' 'Chirp' 'Unique'};
    object.Velocity{n}.Name=name;
end

end