% UNDER CONSTRUCTION
%
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

% uncertainty analysis

end