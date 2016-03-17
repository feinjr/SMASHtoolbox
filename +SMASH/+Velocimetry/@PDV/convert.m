% convert Convert raw output to frequency/velocity


% This method converts frequency results from the "analyze" method to
% velocity.  The standard conversion uses the object's Wavelength and
% ReferenceFrequency (B0) settings to convert beat frequency (B) to
% velocity (v).
%     v=(Wavelength/2)*(B-B0);
% Alternate conversions can be defined in a custom function.
%     >> object=configure(object,'ConvertFunction',@myfunc);
% The function handle "myfunc" must accept two inputs (t and B) and return
% a single output (v).
%
% This method is automatically called within the "analyze" method.  It
% should only be called manually when the conversion function, wavelength,
% or reference frequency are changed.
%
% See also PDV, configure
%

%
% created February 23, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=convert(object,ConvertFunction)

% define standard conversion
lambda=object.Settings.Wavelength;
f0=object.Settings.ReferenceFrequency;
    function velocity=standardConvert(index,time,frequency) %#ok<INUSL>
        velocity=(lambda/2)*(frequency-f0);
    end

% manage input
if (nargin<2) || isempty(ConvertFunction)
    ConvertFunction=@standardConvert;
end
assert(isa(ConvertFunction,'function_handle'),...
    'ERROR: invalid ConvertFunction');

% cconversion factors
fs=object.SampleRate;
tau=object.BoxcarDuration;
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