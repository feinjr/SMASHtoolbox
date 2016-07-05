function object=create(object,varargin)

Narg=numel(varargin);

% default settings
object.GraphicOptions=SMASH.Graphics.GraphicOptions;
object.GraphicOptions.Title='Bayes Calibration';
object.GraphicOptions.Marker='.';

object.Measurement = []; %User defined measurement settings for use in model

object.ModelSettings = struct;
object.ModelSettings.Model = @func; %Function handle defining the model

object.VariableSettings = struct;
object.VariableSettings.Names = {}; %List of strings
object.VariableSettings.PriorType = {}; %List of strings
object.VariableSettings.PriorSettings = {}; %Array correspodning to type for each element
object.VariableSettings.ProposalStd = []; %Array of proposal jumps for each variable (opt)
object.VariableSettings.HyperSettings = {}; % {'PriorType',[settings],proposal jump} (opt)
object.VariableSettings.Infer = []; %Array of logicals (opt)
object.VariableSettings.Share = []; %Array of logicals (opt)

object.MCMCSettings.StartPoint = []; %Array of starting point of inferred variables
object.MCMCSettings.ChainSize = 1e3;
object.MCMCSettings.DelayedRejectionScale = 0; % Enables DR algorithm (opt)
object.MCMCSettings.AdaptiveInterval = 0; % Enables AM algorithm (opt)



object.MCMCResults.InferredVariables = {};
object.MCMCResults.CutVariables = {};
object.MCMCResults.InferredChain = {};
object.MCMCResults.CutChain = {};
object.MCMCResults.AcceptanceRate = {};

% manage input
if (Narg == 0)
    %Create empty object
else
    error('ERROR: unable to create BayesCalibration object from this input');
end


end