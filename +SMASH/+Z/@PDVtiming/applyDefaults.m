% This method applies default settings for the constructor.  It is hidden
% from the user.
function applyDefaults(object)

% general parameters
object.DigitizerScaling=1e9;
object.DerivativeSmoothing=1;
object.FiducialRange=10;
object.OBRwidth=2;

% diagnostic channels
setupDiagnostic(object,1:8); %delays?

% digitizers
setupDigitizer(object,[1 2]); % delays?
setupDigitizerChannel(object,[1 2 3 4]);

% probes
setupProbe(object,1:8);

N=10;
index=transpose(1:10);
transit=nan(N,1);
object.OBRreference=[index transit];


end