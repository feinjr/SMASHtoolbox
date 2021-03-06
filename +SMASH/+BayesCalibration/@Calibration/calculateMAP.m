% Calculate the maximum a posteriori 
%
% Calculates the set of parameters which maximizes the likelihood function
%
%    >> [params] = calculateMAP(object);
% 
% where it starting point is object.MCMCSettings.StartPoint. Note: for
% uniform priors this results in an MLE estimate.
%
% See also BayesCalibration, Calibration, runMCMC
% 

%
% created July 18, 2016 by Justin Brown (Sandia National Laboratories)
%
function params = calculateMAP(varargin)

% if ~isvector(x)
%     error('ERROR : x must be a 1D array');
% end
% 
% if nargout == 1
%     r = object.ModelSettings.Model(object,x);
%     varargout{1} = r; 
% elseif nargout == 2
%     [r,sig2] = object.ModelSettings.Model(object,x);
%     varargout{1} = r; 
%     varargout{2} = sig2; 
% else
%     error('ERROR : Invalid number of outputs');
% end
% 

obj={}; objcount = 0;
for ii = 1:nargin
    if isobject(varargin{ii})
        objcount = objcount+1;
        obj{objcount} = varargin{ii};
    end
end
Nexp = numel(obj);


%Prior settings bookkeeping
InferredVariables = {};
for ii = 1:Nexp
    
    %Default to all inferred
    if isempty(obj{1}.VariableSettings.Infer)
        obj{ii}.VariableSettings.Infer = true(size(obj{1}.VariableSettings.Names));
    end
    
    if ii == 1
        addinferred{ii} = obj{ii}.VariableSettings.Infer;
        I_update = obj{ii}.MCMCSettings.StartPoint(obj{ii}.VariableSettings.Infer);
    else
        addinferred{ii} = obj{ii}.VariableSettings.Infer & ~obj{ii}.VariableSettings.Share;
        I_update = horzcat(I_update,obj{ii}.MCMCSettings.StartPoint(addinferred{ii}));
    end
    samps{ii} = obj{ii}.MCMCSettings.StartPoint;
    addn = obj{ii}.VariableSettings.Names(addinferred{ii});
    InferredVariables= {InferredVariables{:},addn{:}};
    
end
count = 0;
for eNum = 1:length(obj)
    for sNum=1:length(samps{eNum})
        if addinferred{eNum}(sNum)
        count = count+1;
        priorfunc{count}= str2func(obj{eNum}.VariableSettings.PriorType{sNum});
        priorvals{count} = num2cell(obj{eNum}.VariableSettings.PriorSettings{sNum});
        end            
    end
end 



%Calculate error covariance first so it's not done every time
r0={size(obj)}; 
sig2={size(obj)}; 
for ii = 1:Nexp
    [rt, sig2t]= calculateResiduals(obj{ii},obj{ii}.MCMCSettings.StartPoint);
    sig2{ii} = sig2t;
    if isvector(sig2{ii})
         sig2inv{ii} = inv(diag(sig2t));
    else
        sig2inv{ii} = inv(sig2t);
    end
end



% Use fminsearch to find maximum likelihood
params = fminsearch(@fMAP,I_update);

% % Print Results
% fprintf('Maximum a posteriori (MAP) estimate:\n');
% for ii = 1:length(params);
%     fprintf('\t%s\t%10.5g\n',InferredVariables{ii},params(ii));
% end

    
%% fminsearch function    
    function l = fMAP(x)
        
        %Parse input
        trialparams = x;
        count = 0; trialsamps = samps;
        for eNum = 1:length(obj)
            for sNum=1:length(samps{eNum})
                if addinferred{eNum}(sNum)
                count = count+1;
                trialsamps{eNum}(sNum) = trialparams(count);
                end            
            end
        end 

        
        %Likelihoods
        lik = 0;
        for ii = 1:Nexp 
            %Update shared variables
            trialsamps{ii}(obj{ii}.VariableSettings.Share) = trialsamps{1}(obj{ii}.VariableSettings.Share);
            lik(ii) = calculateLogLikelihood(obj{ii},trialsamps{ii},sig2{ii},sig2inv{ii});
        end
        
        
        %Priors
        lprior = zeros([1,length(InferredVariables)]);
        for ii = 1:length(I_update);
            lprior(ii) = priorfunc{ii}(priorvals{ii}{:},trialparams(ii));
        end

                  
        l = -sum(lik)-sum(lprior);
        
    end
        

end
