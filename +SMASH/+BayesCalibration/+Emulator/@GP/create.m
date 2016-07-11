function object=create(object,varargin)

Narg=numel(varargin);

% default settings
object.GraphicOptions=SMASH.Graphics.GraphicOptions;
object.GraphicOptions.Title='GP Emulator';
object.GraphicOptions.Marker='.';

object.NumberVariables = 0;
object.NumberResponses = 0;
object.VariableData = [];
object.ResponseData = [];
object.VariableNames = {};
object.ResponseNames = {};
object.Grid = [];

p=struct();
p.Theta0 = [];
p.Theta0_LowerBound = [];
p.Theta0_UpperBound = [];
p.TrendFunction = @regpoly1;
p.CorrFunction = @corrgauss;

object.DACEFit = [];


% manage input
if (Narg == 0)
    %Create empty object
elseif (Narg==2) && isnumeric(varargin{1}) && isnumeric(varargin{2})
    [nd md] = size(varargin{1}); % Size of design sites
    [nr mr] = size(varargin{2}); % Size of responses
    if nd ~= nr
        error ('ERROR : Design sites and response data must have same number of rows');
    end
    object.VariableData = varargin{1}
    object.ResponseData = varargin{2};
    object.NumberVariables = md;
    object.NumberResponses = mr;
    
    p.Theta0 = ones(1,object.NumberVariables);
    p.Theta0_LowerBound = ones(1,object.NumberVariables)*1e-4;
    p.Theta0_UpperBound = ones(1,object.NumberVariables)*1e4;
    
    
else
    error('ERROR: unable to create GP object from this input');
end



object.Settings=p;


end