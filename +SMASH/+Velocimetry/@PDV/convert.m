% convert Convert frequency to velocity
%


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

% apply conversion function
N=numel(object.BeatFrequency);
object.Velocity=cell(1,N);
for n=1:N
    t=object.BeatFrequency{n}.Grid;
    f=object.BeatFrequency{n}.Data(:,1);
    v=ConvertFunction(n,t,f);
    df=object.BeatFrequency{n}.Data(:,4);
    dv=df*correction*(lambda/2);
    object.Velocity{n}=SMASH.SignalAnalysis.SignalGroup(t,[v(:) dv(:)]);
    object.Velocity{n}.GridLabel='Time';
    object.Velocity{n}.DataLabel='';
    object.Velocity{n}.Legend={'Velocity','Uncertainty'};    
    object.Velocity{n}.Name=object.BeatFrequency{n}.Name;
end

end