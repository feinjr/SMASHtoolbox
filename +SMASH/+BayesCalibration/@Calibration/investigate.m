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
        variables = 'allinferred';
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
        cloudvars = {'phi'};
        cloudtable  = object.MCMCResults.HyperParameterChain;
    end
    
    if strcmpi(variables,'allinferred')
        cloudvars = horzcat(object.MCMCResults.InferredVariables,'phi');
        cloudtable  = horzcat(object.MCMCResults.InferredChain,object.MCMCResults.HyperParameterChain);
    end
    
    if strcmpi(variables,'all')
        cloudvars = horzcat(object.MCMCResults.InferredVariables,'phi',object.MCMCResults.CutVariables);
        cloudtable  = horzcat(object.MCMCResults.InferredChain,object.MCMCResults.HyperParameterChain,object.MCMCResults.CutChain);
    end
    
    
    
    
    cloudobj = SMASH.MonteCarlo.Cloud(cloudtable,'table');
    cloudobj = configure(cloudobj,'VariableName',cloudvars);
    
    if nargout==0
        investigate(cloudobj,iterations,span);
    else
        [varargout{1} varargout{2} varargout{3}]=investigate(cloudobj,iterations,span);
    end
    


end