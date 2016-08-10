% Investigate Investigate statistial properties of MCMC chain
%
% This method runs the investigate method for a MonteCarlo.Cloud object on
% the selected chain variables as
%
%       >> [moments,correlations,span]=investigate(object,iterations,span,variables,vnums)
%
% where iterations (default = 1000) are the number of bootstrap
% evaluations, span (default = 0.9) represents the confidence regions which
% can also be specifed as a vector such as [0.05 0.95], variables (default =
% 'inferred') specifies the variables to be pulled from the chain with
% valid options being 'inferred', 'cut', 'hyper', 'all', or 'allinferred',
% and vnums (default = []) specifying a more specific array of variable 
% numbers. 
%

% See also Calibration, SMASH.MonteCarlo.Cloud
%
%
% created June 30, 2016 by Justin Brown (Sandia National Laboratories)
%
function varargout=investigate(object,iterations,span,variables,vnums)
    
    % manage input  
    if (nargin<2) || isempty(iterations)
        iterations=1000;
    end
    assert(SMASH.General.testNumber(iterations,'positive','integer','notzero'),...
      'ERROR: invalid iterations setting');
    if (nargin<3) || isempty(span)
        span=0.9;
    end
    assert(isnumeric(span) && isscalar(span),...
        'ERROR: invalid span setting');
    if nargin < 4 || isempty(variables)
        variables = 'inferred';
    end
        assert(ischar(variables),'ERROR: invalid variables specification. Choose from inferred, cut, hyper, or all');
    
    if nargin < 5
        vnums = [];
    end
        
        
        
    if strcmpi(variables,'inferred')
        cloudvars = object.MCMCResults.InferredVariables;
        cloudtable  = object.MCMCResults.InferredChain;
    end
    
    if strcmpi(variables,'cut')
        cloudvars = object.MCMCResults.CutVariables;
        cloudtable  = object.MCMCResults.CutChain;
    end
    
    if strcmpi(variables,'hyper')      
        cloudtable  = object.MCMCResults.HyperParameterChain;
        [nr nc] = size(cloudtable);
        for ii = 1:nc
            cloudvars{ii} = sprintf('phi%i',ii);
        end
    end
    
    if strcmpi(variables,'allinferred')
        cloudtable  = object.MCMCResults.HyperParameterChain;
        [nr nc] = size(cloudtable);
        for ii = 1:nc
            cloudvars{ii} = sprintf('phi%i',ii);
        end
        cloudvars = horzcat(object.MCMCResults.InferredVariables,cloudvars);
        cloudtable  = horzcat(object.MCMCResults.InferredChain,cloudtable);
    end
    
    
    if strcmpi(variables,'all')
        cloudtable  = object.MCMCResults.HyperParameterChain;
        [nr nc] = size(cloudtable);
        for ii = 1:nc
            cloudvars{ii} = sprintf('phi%i',ii);
        end
        cloudvars = horzcat(object.MCMCResults.InferredVariables,cloudvars,object.MCMCResults.CutVariables);
        cloudtable  = horzcat(object.MCMCResults.InferredChain,cloudtable,object.MCMCResults.CutChain);
    end
    
    
    
    
    if isempty(vnums)
        cloudobj = SMASH.MonteCarlo.Cloud(cloudtable,'table');
        cloudobj = configure(cloudobj,'VariableName',cloudvars);
    else
        cloudobj = SMASH.MonteCarlo.Cloud(cloudtable(:,vnums),'table');
        cloudobj = configure(cloudobj,'VariableName',{cloudvars{vnums}});
    end
    
    
    if nargout==0
        investigate(cloudobj,iterations,span);
    else
        [varargout{1} varargout{2} varargout{3}]=investigate(cloudobj,iterations,span);
    end
    


end