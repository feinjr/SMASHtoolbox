% optimize Optimize model parameters to match measurements

function object=optimize(object,options)

% manage input
if (nargin<2) || isempty(options)
    options=object.OptimizationSettings;
end
try
    optimset(options);
catch
    error('ERROR: invalid optimization settings');
end

% check normal status
if object.AssumeNormal
    type='normal';
else
    type='general';
end

% perform optimization
M=object.NumberMeasurements;
    function value=likelihood(slack)
        object=evaluate(object,'slack',slack);        
        maxdensity=zeros(1,M);
        maxlocation=nan(M,2);
        for m=1:M % iterate over measurements
            measurement=object.MeasurementDensity{m};            
            [temp,location]=findmax(measurement,'original',...
                object.CurvePoints,type);
            if temp > maxdensity(m)
                maxdensity(m)=temp;
                maxlocation(m,:)=location;
            end            
        end
        value=-sum(log(maxdensity))/M; % sign flip converts minimization to maximization                        
    end
slack=fminsearch(@likelihood,object.Slack,options);
object=evaluate(object,'slack',slack);

end