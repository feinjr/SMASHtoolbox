% optimize Optimize model parameters
%
% This method optimizes model parameters against the measurements defined
% in a CurveFit2D object.
%    object=optimize(object); % use options defined in the object
%    object=optimize(object,options); % manual options (see optimset function)
% NOTE: the behavior of this method is senstivie to the AssumeNormal
% property!
%
% By default, this method generates a warning if the optimized curve does
% not pass near every measurment.  This warning can be suppressed as
% follows.
%    object=optimize(object,[],'silent'); % use default options
%    object=optimize(object,options,'silent');
% A logical array indicating measurements missed by the optimized curve is
% returned as a second output.
%    [object,miss]=optimize(...);
%
% See also CurveFit2D, analyze
%

%
% creaed March 8, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function [object,miss]=optimize(object,options,silent)

% manage input
if (nargin<2) || isempty(options)
    options=object.OptimizationSettings;
end
try
    optimset(options);
catch
    error('ERROR: invalid optimization settings');
end

if (nargin<3) || isempty(silent) || strcmpi(silent,'verbose')
    silent=false;
elseif strcmpi(silent,'silent')
    silent=true;
else
    error('ERROR: invalid silent input');
end

% check normal status
if object.AssumeNormal
    type='normal';
else
    type='general';
end

% perform optimization
M=object.NumberMeasurements;
miss=false(1,M);
    function value=likelihood(slack)
        object=evaluate(object,'slack',slack);        
        maxdensity=zeros(1,M);
        maxlocation=nan(M,2);
        miss(:)=false;
        for m=1:M % iterate over measurements
            measurement=object.MeasurementDensity{m};            
            [temp,location]=findmax(measurement,'original',...
                object.CurvePoints,type);
            maxdensity(m)=temp;
            maxlocation(m,:)=location;
            if any(isnan(location))
                miss(m)=true;
            end            
        end
        value=-sum(log(maxdensity))/M; % sign flip converts minimization to maximization                               
    end
slack=fminsearch(@likelihood,object.Slack,options);
object=evaluate(object,'slack',slack);

if ~silent && any(miss)
    message={};
    message{end+1}='Optimized mode misses one or more measurements:';
    message{end+1}='   -A better parameter guess may resolve this problem.';
    message{end+1}='   -A different model may be more appropriate.';
    message{end+1}='   -Specified measurement variances may be too low.';
    message{end+1}='   -There may be measurement outliers.';   
    warning('SMASH:Curvefit2D','%s\n',message{:});
end

end