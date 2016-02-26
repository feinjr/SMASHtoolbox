% analyze Monte Carlo analysis of cloud data
%
%     result=analyze(object,iterations,draws)

%
% This method launches curve fit analysis.  The calling syntax is:
%    >> result=analyze(object,curve,guess,[evaluation],...);
% where the "curve" and "guess" inputs are mandatory.  "curve" specifies
% the fit function of interest.  This function *must* have the format:
%     [x,y]=myfunc(param,evalpoints)
% The first input is an array of adjustable model parameters.  The second
% input is a set of evaluation points for the curve.  In many cases, the
% evaluation points are identical to x, but this is not mandatory.  The fit
% function can modify the evaluation points to capture important
% features (such as breaks), or the function could be parametric in
% nature, i.e. x=x(t), y=y(t).  The "guess" input tells the analysis the
% number of adjustable parameters and serves as the starting point for all
% optimizations.  If no evaluation points are specified, the analysis
% assumes that the function is of the form y=f(x) and that x spans the
% range of data points within the object.
%
% All additional inputs to this method are treated as control options for
% the optimization.  Refer to MATLAB's optimset function for information
% about these options.
%
% See also CloudFitXY
%


function [result,object]=analyze(object,iterations)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=100;
end
test=SMASH.General.testNumber(iterations,'positive','integer') ...
    && (iterations>0);
assert(test,'ERROR: invalid number of iterations');

% check parallel state
parallel=false;
try
    if exist('matlabpool','file') && (matlabpool('size')>0) %#ok<DPOOL>
        parallel=true; % MATLAB 2013a and earlier
    end
catch
    if ~isempty(gcp('nocreate'))
        parallel=true; % MATLAB 2014a and later
    end
end

% determine variable ranges
xb=[+inf -inf];
yb=[+inf -inf];
for k=object.ActiveClouds
    moments=object.CloudData{k}.Moments;
    xb(1)=min(xb(1),moments(1,1));
    xb(2)=max(xb(2),moments(1,1));
    yb(1)=min(yb(1),moments(2,1));
    yb(2)=max(yb(2),moments(2,1));
end

% verify model, refine guess, and setup result array
try
    param=fitModel(object,xb,yb);
catch
    error('ERROR: missing or invalid model function');
end
result=nan(numel(param),iterations);
result(:,1)=param;

% perform analysis
if parallel
    parfor m=2:iterations
        result(:,m)=fitModel(object,xb,yb);
    end
else
    for m=2:iterations
        result(:,m)=fitModel(object,xb,yb);
    end
end

result=transpose(result);

% manage output
result=SMASH.MonteCarlo.Cloud(result,'table');
if nargout>=2
    best=result.Moments(:,1);
    object=setupModel(object,[],best,[],xb,yb);
end

end

function result=fitModel(object,xb,yb)

[points,weights,ielements,group]=drawPoints(object);

NumberParameters=numel(object.Model.Parameters);
result=nan(NumberParameters,1);
    function chi2=residual(slack)
        % update curve
        object=evaluateModel(object,slack,xb,yb);
        result=object.Model.Parameters;        
        segments=curve2segments(object.Model.Curve);
        % weighted sum of minimum Mahalanobis distances
        chi2=0;
        WeightSum=0;
        for k=1:size(group,1)                        
            index=group(k,1):group(k,2);
            D2=calculateDistance(segments,points(index,:),ielements);
            if any(D2<0)
                keyboard;
            end
            chi2=chi2+sum(D2.*weights(k));
            WeightSum=WeightSum+weights(k)*numel(index);
        end
        chi2=chi2/WeightSum;        
    end
fminsearch(@residual,object.Model.Slack,object.OptimizationSettings);

end