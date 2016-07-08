% summarize Calculate actual moments and corelations
%
% This method summarizes the statistical properties of the Data stored in a
% Calibration object.  When called without outputs:
%
%   >> summarize(object);
%
% the moments array and correlation matrix are printed in the command
% window.  This information can also be returned as outputs.
%
%    >> [moments,correlations]=summarize(object);
%
% An optional setting can be input to specify which variables to summarize
%   
%   >> [moments,correlations]=summarize(object,variables)
%
% where valid options include 'inferred', 'cut', 'hyper', or 'all'
%
% See also Calibration, SMASH.MonteCarlo.Cloud
%
%
% created June 30, 2016 by Justin Brown (Sandia National Laboratories)
%
function varargout=summarize(object,variables)
    
    % manage input
    if nargin < 2 || isempty(variables)
        variables = 'Inferred';
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
        summarize(cloudobj);
    else
        [varargout{1} varargout{2}]=summarize(cloudobj);
    end
    
    

end