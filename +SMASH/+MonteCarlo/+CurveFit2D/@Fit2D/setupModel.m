% setupModel Setup fit model
%
% This method defines the model associated with a 2D cloud fit.  Models are
% defined by a target function handle and a parameter array.
%     object=setModel(object,target,param);
%
% The target function must accept three inputs and return one output.
%     output=target(param,xspan,yspan);
%       param  : current parameter state (column vector)
%       xspan : characteristic span of variable x ([xmin xmax])
%       yspan : characteristic span of varaible y ([ymin ymax]);
%       output : two-column array of [x y] values
% Points in the output array will be connected in a piecewise linear
% fashtion with gaps wherever NaN values are found.
%
% The input "param" must be a column vector of parameter values understood
% by the target function.  Any valid parameter for the model can be
% used---the important thing is the number of parameters, which defines the
% degrees of freedom when the model is optimized with resepct to a dataset.
%  Usually, a set of plausible guess values are specified.
%
% See also CloudFit2D, setParameter
%

%
% created October 30, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=setupModel(object,target,param,bounds,xspan,yspan)

% manage input
assert(nargin>=3,'ERROR: invalid number of inputs');

if isempty(target)
    target=object.Model.Function;
else
    assert(isa(target,'function_handle'),...
        'ERROR: invalid function handle');
end

if isempty(param)
    param=object.Model.Parameters;
else
    assert(isnumeric(param),'ERROR: invalid parameters');
end

NumberParameters=numel(param);
if (nargin<4) || isempty(bounds)       
    bounds=object.Model.Bounds;
else
    [Nrow,Ncol]=size(bounds);
    assert(isnumeric(bounds) && (Nrow==NumberParameters) && (Ncol==2),...
        'ERROR: invalid bounds');
    bounds=sort(bounds,2);
    assert(all((bounds(:,2)-bounds(:,1))>0),'ERROR: invalid bounds');
end
if isempty(bounds)
    bounds=repmat([-inf +inf],[NumberParameters 1]);
end

if any(nargin < 5) || isempty(xspan) || isempty(yspan);
    evaluate=false;
else
    assert(isnumeric(xspan) && numel(xspan)==2,'ERROR: invalid x span');
    assert(isnumeric(yspan) && numel(yspan)==2,'ERROR: invalid y span');
    evaluate=true;
end

% assign settings
object.Model.Function=target;
object.Model.Parameters=param(:);
object.Model.Bounds=bounds;

% calculate slack variables
object.Model.Slack=nan(NumberParameters,1);
object.Model.SlackReference=nan(NumberParameters,3);
for n=1:NumberParameters
    if all(isinf(bounds(n,:))) % unbounded
        object.Model.SlackReference(n,1)=param(n);
        object.Model.Slack(n)=0;
    elseif isinf(bounds(n,1)) % maximum bound
        % no reference value
        object.Model.Slack(n)=sqrt(bounds(n,2)-param(n));
    elseif isinf(bounds(n,2)) % minimum bound
        % no reference value
        object.Model.Slack(n)=sqrt(param(n)-bounds(n,1));
    else % two-sided bound
        pmid=(bounds(n,2)+bounds(n,1))/2;
        pamp=(bounds(n,2)-bounds(n,1))/2;
        qmid=-asin((param(n)-pmid)/pamp);
        object.Model.SlackReference(n,1)=pmid;
        object.Model.SlackReference(n,2)=pamp;
        object.Model.SlackReference(n,3)=qmid;
        object.Model.Slace(n)=0;
    end
end

% update curve
if evaluate
    object=evaluateModel(object,object.Model.Slack,xspan,yspan);
else
    warning('SMASH:CloudFit2D',...
        'Model curve not updated because of missing x/y spans');
    object.Model.Curve=[];
end

end