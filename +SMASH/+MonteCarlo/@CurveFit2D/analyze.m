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
function [result,miss]=analyze(object,iterations,silent)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=100;
end

if (nargin<3) || isempty(silent) || strcmpi(silent,'verbose')
    silent=false;
elseif strcmpi(silent,'silent')
    silent=true;
else
    error('ERROR: invalid silent input');
end

% Monte Carlo simulations  
miss=nan(object.NumberMeasurements,iterations);
result=nan(numel(object.Parameter),iterations);
if SMASH.System.isParallel
    parfor k=1:iterations
        [temp1,temp2]=process(object);
        result(:,k)=temp1(:);
        miss(:,k)=temp2(:);
    end
else
    for k=1:iterations
        [temp1,temp2]=process(object);
        result(:,k)=temp1(:);
        miss(:,k)=temp2(:);
    end
end

% report missed points
if ~silent && any(miss(:))
    message={};
    message{end+1}='Some measurements were missed during optimization';
    message{end+1}='Parameter results may need to trimmed';
    warning('SMASH:Curvefit2D','%s\n',message{:});
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

function [parameter,miss]=process(object)

if object.AssumeNormal
    object=recenter(object,'normal');
else
    object=recenter(object,'general');
end

[object,miss]=optimize(object,[],'silent');
parameter=object.Parameter;

end