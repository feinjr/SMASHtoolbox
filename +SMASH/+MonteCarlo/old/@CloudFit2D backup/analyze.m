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


function result=analyze(object,iterations)

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

% perform analysis
result=nan(object.Model.NumberParameters,iterations);
if parallel
    parfor m=1:iterations
        temp=fitModel(object);
        result(:,m)=temp(:);
    end
else
    for m=1:iterations
        temp=fitModel(object);
        result(:,m)=temp(:);
    end
end

result=transpose(result);

% manage output
result=SMASH.MonteCarlo.Cloud(result,'table');

end

function result=fitModel(object)

[points,weights,covariance,group]=drawPoints(object);
temp=optimize(object.Model,points,weights,covariance,group);
result=temp.Parameters;

end