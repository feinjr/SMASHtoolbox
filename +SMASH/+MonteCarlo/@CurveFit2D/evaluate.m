% evaluate Evaluate model function
%
% This function evaluates the model function for a particular parameter
% state.
%    object=evaluate(object,'parameter',parameter);
%    object=evaluate(object,'slack',slack)
function object=evaluate(object,mode,parameter)

% manage input
switch mode
    case 'slack'
        slack=parameter;
        parameter=nan(size(slack));
        for n=1:numel(parameter)
            switch object.BoundType
                case 'nobounds'
                    parameter(n)=slack(n);
                case 'maxbound'
                    parameter(n)=object.Bound(n,2)-slack(n)^2;
                case 'minbound'
                    parameter(n)=object.Bound(n,1)+slack(n)^2;
                case 'twobounds'
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

% evaluate model function and construct segments
points=object.Model(param,object.XDomain,object.YDomain);
object.CurvePoints=points;

Npoints=size(points,1);
while (n<Npoints)
    % YOU ARE HERE
end


end