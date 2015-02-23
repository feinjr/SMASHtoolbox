% convert Convert frequency results to velocity
%
% This method converts frequency results from the "analyze" method to
% velocity.  The standard conversion is:
%     velocity=(lambda/2)*(frequency-f0);
% using the object's wavelength (lambda) and reference frequency (f0)
% settings.  Alternate conversions can be specified by changing the
% ConvertFunction setting.
%
% This method is automatically called by the "analyze" method.  It should
% only be called manually when the conversion function, wavelength, or
% reference frequency are changed.
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

location=object.Results.Location;
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