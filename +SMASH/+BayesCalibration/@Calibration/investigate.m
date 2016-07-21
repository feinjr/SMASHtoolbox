% Investigate Investigate statistial properties of MCMC chain
%
%
% See also Calibration, SMASH.MonteCarlo.Cloud
%
%
% created June 30, 2016 by Justin Brown (Sandia National Laboratories)
%
function varargout=investigate(object,iterations,span,variables)
    
    % manage input  
    if (nargin<2) || isempty(iterations)
        iterations=1000;
    end
    assert(SMASH.General.testNumber(iterations,'positive','integer','notzero'),...
      'ERROR: invalid iterations setting');
    if (nargin<3) || isempty(span)
        span=0.90;
    end
    assert(isnumeric(span) && isscalar(span),...
        'ERROR: invalid span setting');
    if nargin < 4 || isempty(variables)
        variables = 'inferred';
    end
        assert(ischar(variables),'ERROR: invalid variables specification. Choose from inferred, cut, hyper, or all');
    
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
    
    
    
    
    cloudobj = SMASH.MonteCarlo.Cloud(cloudtable,'table');
    cloudobj = configure(cloudobj,'VariableName',cloudvars);
    
    if nargout==0
        investigate(cloudobj,iterations,span);
    else
        [varargout{1} varargout{2} varargout{3}]=investigate(cloudobj,iterations,span);
    end
    


end