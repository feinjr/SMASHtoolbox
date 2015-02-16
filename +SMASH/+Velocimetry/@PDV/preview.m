%     >> object=preview(object)
%     >> object=preview(object,{'duration' [duration advance]});
%     >> object=preview(object,{'points' [points skip]});
%     >> object=preview(object,{'blocks' [number overlap]});
%
%     >> preview(object);
%     >> preview(object,target);
function varargout=preview(object,varargin)

% display preview
if nargout==0
    if isempty(object.Preview)
        fprintf('Generating preview\n');
        object=preview(object);
    end
    if nargin==1
        view(object.Preview);
    else
        view(object.Preview,varargin{:});
    end 
    return
end

% generate preview
if (nargin<2) || isempty(varargin{1})
    [x,~]=limit(object.Measurement);
    points=ceil(numel(x)/1000);
    type='points';
    param=points;
else
    type=varargin{1}{1};
    param=varargin{1}{2};
end

previous=object.Measurement.Partition;
object.Measurement=partition(object.Measurement,type,param);
object.Preview=analyze(object.Measurement);
object.Measurement=partition(object.Measurement,previous);

varargout{1}=object;

end