% evaluate Evaluate model function
%
% This function evaluates the model function for a particular parameter
% state.
%    object=evaluate(object,'parameter',parameter);
%    object=evaluate(object,'slack',slack)
%
% NOTE: this method is meant to have protected access and should be hidden
% from the end user.
%

%
% created February 29, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=evaluate(object,mode,parameter)

% manage input
switch mode
    case 'slack'
        slack=parameter;
        bound=object.Bound;
        parameter=nan(size(slack));
        for n=1:numel(parameter)
            if all(isinf(bound(n,:))) % unbounded parameter
                parameter(n)=slack(n);
            elseif isinf(bound(n,1)) % maximum bound
                parameter(n)=bound(n,2)-slack(n)^2;
            elseif isinf(bound(n,2)) % minimum bound
                parameter(n)=bound(n,1)+slack(n)^2;
            else % two-sided bound
                mid=(bound(n,2)+bound(n,1))/2;
                amp=(bound(n,2)-bound(n,1))/2;
                parameter(n)=mid+amp*sin(slack(n));
            end
        end
    case 'parameter'
        % do nothing
    otherwise
        error('ERROR: invalid evaluate mode');
end
object.Parameter=parameter;

% evaluate model function
points=object.Model(parameter,object.XDomain,object.YDomain); % model function MUST accept three inputs
Npoints=size(points,1);
assert(Npoints>=2,...
    'ERROR: model function must generate at least two data points');
object.CurvePoints=points;
try
    points2segments(points);
catch
    error('ERROR: model function generated invalid data point(s)');
end

end