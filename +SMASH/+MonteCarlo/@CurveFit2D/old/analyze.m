% analyze Perform Monte Carlo analysis
%
% This method uses Monte Carlo analysis to estimate the plausible variation
% of model parameters due to measurement uncertainty.
%    result=analyze(object); % 100 iterations (default)
%    result=analyze(obect,iterations);
% During each iteration, model parameters are optimized using a set of
% randomly shifted measurements (based on their probability density).  The
% output "result" is a Cloud object derived from the parameters generated
% from this process.
%

% By default, this method generates a warning if the optimized curve does
% not pass near every measurment.  This warning can be suppressed as
% follows.
%    object=optimize(object,iterations,'silent');
% A logical array indicating measurements missed by the optimized curve is
% returned as a second output.
%    [object,miss]=analyze(...);
%
% See also CurveFit2D, optimize
% 

%
% creaed March 8, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function [result,success]=analyze(object,iterations)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=100;
end

% Monte Carlo simulations  
result=nan(numel(object.Parameter),iterations);
success=0;
if SMASH.System.isParallel
    parfor k=1:iterations
        [temp,flag]=process(object);
        result(:,k)=temp(:);
        if flag==1
            success=success+1;
        end
    end
else
    for k=1:iterations
        [temp,flag]=process(object);
        result(:,k)=temp(:);
        if flag==1
            success=success+1;
        end
    end
end

% report problems
if success < iterations  
    warning('SMASH:CurveFit2D',...
        ['Only %d of %d optimizations converged successfully\n\t'...
        'Looser tolerances or more iterations/evaluations may be needed'],...
        success,iterations);
end

% generate results
result=transpose(result);
result=SMASH.MonteCarlo.Cloud(result,'table');
name=result.VariableName;
for p=1:result.NumberVariables
    name{p}=sprintf('Parameter %d',p);
end
result=configure(result,'VariableName',name);

end

function [parameter,flag]=process(object)

if object.AssumeNormal
    object=recenter(object,'normal');
else
    object=recenter(object,'general');
end

[object,flag]=optimize(object);
parameter=object.Parameter;

end