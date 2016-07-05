% Fit the Gaussian Process
%
% This method trains the Gaussian Process, storing the results in the
%    >> object=fit(object);
% 
% Options can be specified as pairs containing a specifying string followed
% by a relevant value. Currently, only one option is supported: 'SameTheta'
% is true/false flag which uses the same correlation parameters for each
% residual if true. If false (default), a seperate set of parameters is fit 
% for each residual, resulting in a cell array of GP fits - this can 
% significantly increase computation time. 
%
%
% See also GP, evaluate
% 

%
% created June 20, 2016 by Justin Brown (Sandia National Laboratories)
%
function object=fit(object,varargin)

Narg=numel(varargin);

% Default settings
sametheta = true;

options = [];
if Narg > 1 
    if rem(Narg/2,1) ~=0
        error('ERROR : Invalid option settings');
    end
    options = varargin(1:2:Narg);    
    optionvals = varargin(2:2:Narg+1);     
end   

if ~isempty(options)
    validoptions = {'SameTheta'};
    for i=1:numel(options);
        validStr{i} = validatestring(options{i},validoptions);
    end

    ST = strcmpi(validoptions{1},validStr);
    if any(ST)
        sametheta = optionvals{ST};
    end
end

theta = object.Settings.Theta0;
lb = object.Settings.Theta0_LowerBound;
ub = object.Settings.Theta0_UpperBound;

% Fit using same theta for every residual
if sametheta
    disp('Fitting GP using same correlation coefficients for all residuals')
    object.DACEFit = dacefit(object.VariableData,object.ResponseData,object.Settings.TrendFunction,object.Settings.CorrFunction,theta,lb,ub);
else
% Fit using a different theta for each residual, store as cell array of
% DACEFit structures
    wb=SMASH.MUI.Waitbar('Training Gaussian Process Model');
    disp('Fitting GP using different correlation coefficients for each residual')
    object.DACEFit = {};
    for i = 1:object.NumberResponses
        object.DACEFit{i} = dacefit(object.VariableData,object.ResponseData(:,i),object.Settings.TrendFunction,object.Settings.CorrFunction,theta,lb,ub);
        update(wb,i/object.NumberResponses);
    end
    delete(wb);

end