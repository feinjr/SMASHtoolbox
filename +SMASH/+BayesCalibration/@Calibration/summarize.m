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
        variables = 'allinferred';
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
        cloudtable  = object.MCMCResults.HyperChain;
        [nr nc] = size(cloudtable);
        for ii = 1:nc
            cloudvars{ii} = sprintf('phi%i',ii);
        end
    end
    
    if strcmpi(variables,'allinferred')
        cloudtable  = object.MCMCResults.HyperChain;
        [nr nc] = size(cloudtable);
        for ii = 1:nc
            cloudvars{ii} = sprintf('phi%i',ii);
        end
        cloudvars = horzcat(object.MCMCResults.InferredVariables,cloudvars);
        cloudtable  = horzcat(object.MCMCResults.InferredChain,cloudtable);
    end
    
    
    if strcmpi(variables,'all')
        cloudtable  = object.MCMCResults.HyperChain;
        [nr nc] = size(cloudtable);
        for ii = 1:nc
            cloudvars{ii} = sprintf('phi%i',ii);
        end
        cloudvars = horzcat(object.MCMCResults.InferredVariables,cloudvars,object.MCMCResults.CutVariables);
        cloudtable  = horzcat(object.MCMCResults.InferredChain,cloudtable,object.MCMCResults.CutChain);
    end
    
    
%     if isempty(vnums)
%         cloudobj = SMASH.MonteCarlo.Cloud(cloudtable,'table');
%         cloudobj = configure(cloudobj,'VariableName',cloudvars);
%     else
%         cloudobj = SMASH.MonteCarlo.Cloud(cloudtable(:,vnums),'table');
%         cloudobj = configure(cloudobj,'VariableName',{cloudvars{vnums}});
%     end
%     
%     if nargout==0
%         summarize(cloudobj);
%     else
%         [varargout{1} varargout{2}]=summarize(cloudobj);
%     end

    % variable names
    if ~isempty(vnums)
        cloudvars = {cloudvars{vnums}};
    end


    % variable moments
    [nr nc] = size(cloudtable);
    moments=nan(nc,4);
    for n=1:nc
        column=cloudtable(:,n);
        moments(n,1)=sum(column)/nr; % mean
        column=column-moments(n,1);
        temp=column.*column;
        L=sum(temp)/nr;
        moments(n,2)=L; % variance 
        temp=temp.*column;
        moments(n,3)=sum(temp)/nr/(L^(3/2)); % skewness
        temp=temp.*column;
        moments(n,4)=sum(temp)/nr/(L^2)-3; % excess kurtosis
    end
    
    % variable correlations
    correlations=corrcoef(cloudtable);
    
    %Use standard deviation in ouput
    pmom = moments;
    pmom(:,2) = sqrt(pmom(:,2));
    
    % handle output
    if nargout==0
        fprintf('Statistical moments:\n');
        width=cellfun(@length,cloudvars);
        width=max(width);    
        format=['\t' sprintf('%%%ds',width) '%10s%10s%10s%10s\n'];
        fprintf(format,'','mean','error','skewness','kurtosis');
        format=['\t' sprintf('%%%ds',width) '%#+10.4g%#+10.3g%#+10.3g%#+10.3g\n'];
        for n=1:nc
            fprintf(format,cloudvars{n},pmom(n,:));
        end    

        fprintf('Correlations:\n');
        format=repmat('%+10.3f ',[1 nc]);
        format=['\t' format '\n'];
        fprintf(format,correlations);
    else
        varargout{1}=moments;
        varargout{2}=correlations;
    end
    
    

end