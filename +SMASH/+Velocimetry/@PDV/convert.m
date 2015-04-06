% convert Convert frequency results to velocity
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
function object=convert(object)

% frequency to velocity conversion
lambda=object.Settings.Wavelength;
f0=object.Settings.ReferenceFrequency;
    function velocity=standardConvert(~,frequency)
        velocity=(lambda/2)*(frequency-f0);
    end

location=object.Results.BeatFrequency;
if isempty(object.Settings.ConvertFunction)
    v=standardConvert(location.Grid,location.Data);
else
    v=feval(object.Settings.ConvertFunction,location.Grid,location.Data);
end
object.Results.Velocity=SMASH.SignalAnalysis.SignalGroup(location.Grid,v);
object.Results.Velocity.GridLabel='Time';
object.Results.Velocity.DataLabel='Velocity';

% uncertainty analysis (UNDER CONSTRUCTION)

end