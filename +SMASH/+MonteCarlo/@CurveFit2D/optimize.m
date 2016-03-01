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
M=object.NumberMeasurements;
isnormal=false(1,M);
for k=1:M
    isnormal(k)=object.MeasurementDensity{k}.IsNormal;
end
if object.AssumeNormal
    isnormal(:)=true;
end

% perform optimization
    function value=likelihood(slack)
        object=evaluate(object,'slack',slack);        
        maxdensity=zeros(1,M);
        for m=1:M % iterate over measurements
            measurement=object.MeasurementDensity{m};
            points=bsxfun(@minus,object.CurvePoints,measurement.Original.Mode);
            points=points*measurement.Matrix.Forward;
            points(isinf(object.CurvePoints))=inf;
            try
                segments=points2segments(points);
            catch
                error('ERROR: model returned invalid curve point(s)');
            end
            N=size(segments,1);
            for n=1:N % iterate over segments
                % normal density analysis
                u0=segments(n,1);
                v0=segments(n,2);
                Lu=segments(n,3);
                Lv=segments(n,4);
                etamax=segments(n,5);
                uc=measurement.Scaled.Mode(1);
                vc=measurement.Scaled.Mode(2);
                uvar=measurement.Scaled.Var(1);
                vvar=measurement.Scaled.Var(2);
                eta_peak=(u0-uc)*Lu/uvar+(v0-vc)*Lv/vvar;
                eta_peak=-eta_peak/(Lu^2/uvar+Lv^2/vvar);
                if (eta_peak>0) && (eta_peak<etamax)
                    eta=[0; eta_peak; 1];
                else
                    eta=[0; 1];
                end
                u=u0+eta*Lu;
                v=v0+eta*Lv;
                temp=lookup(object,m,'scaled',[u v]);
                temp=max(temp)*measurement.Matrix.Jacobian;
                maxdensity(m)=max(maxdensity(m),temp);
                % non-normal analysis
                if isnormal(n)
                   continue
                end
                % look up density
            end
        end
        value=-sum(log(maxdensity))/M; % sign flip converts minimization to maximization                        
    end
slack=fminsearch(@likelihood,object.Slack,options);
object=evaluate(object,'slack',slack);

end