function object=evaluateModel(object,slack,xb,yb)

NumberParameters=numel(object.Model.Parameters);
param=nan(NumberParameters,1);

% convert slack variables to parameters
for n=1:NumberParameters
    if all(isinf(object.Model.Bounds(n,:))) % unbounded parameter
        p0=object.Model.SlackReference(n,1);
        param(n)=p0+slack(n);
    elseif isinf(object.Model.Bounds(n,1)) % right boundary
        param(n)=object.Model.Bounds(n,2)-slack(n)^2;
    elseif isinf(object.Model.Bounds(2)) % left boundary
        param(n)=object.Model.Bounds(n,1)+slack(n)^2;
    else % two-sided boundary
        pmid=object.Model.SlackReference(n,1);
        pamp=object.Model.SlackReference(n,2);
        qmid=object.Model.SlackReference(n,3);
        param(n)=pmid+pamp*sin(slack(n)-qmid);
    end
end
object.Model.Slack=slack;
object.Model.Parameters=param;

% evaluate function
object.Model.Curve=object.Model.Function(param,xb,yb);

end