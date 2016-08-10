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
% where valid options include 'inferred', 'cut', 'hyper', 'all', or
% 'allinferred'
%
% See also Calibration, SMASH.MonteCarlo.Cloud
%
%
% created June 30, 2016 by Justin Brown (Sandia National Laboratories)
%
function varargout=summarize(object,variables,vnums)
    
    % manage input
    if nargin < 2 || isempty(variables)
        variables = 'Inferred';
    end
    
    if nargin < 3 
        vnums = [];
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
    
    
    
    
    
    if isempty(vnums)
        cloudobj = SMASH.MonteCarlo.Cloud(cloudtable,'table');
        cloudobj = configure(cloudobj,'VariableName',cloudvars);
    else
        cloudobj = SMASH.MonteCarlo.Cloud(cloudtable(:,vnums),'table');
        cloudobj = configure(cloudobj,'VariableName',{cloudvars{vnums}});
    end
    
    if nargout==0
        summarize(cloudobj);
    else
        [varargout{1} varargout{2}]=summarize(cloudobj);
    end
    
    

end