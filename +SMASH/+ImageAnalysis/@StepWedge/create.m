% This method filles in the Settings and Results property during object
% creation
function object=create(object)

% general set up
object.Measurement.GraphicOptions.Title='Step wedge';

% set up settings structure
settings=struct();
settings.StepLevels = object.DefaultStepLevels;
settings.StepOffsets = object.DefaultStepOffsets;

%settings.CalibrationRange=[0.025 0.975]; % allowed calibration range
settings.DerivativeParams= object.DefaultDerivativeParams; % [order nhood]

settings.HorizontalMargin=object.DefaultHorizontalMargin; % fractional
settings.VerticalMargin=object.DefaultVerticalMargin; % fraction

object.Settings=settings;

% set up results structure
results=struct();
results.RegionTable=[]; % Region of interest table ([x0 y0 Lx Ly])
results.TransferTable=[];
results.TransferPoints=[];

object.Results=results;

end