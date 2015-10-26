% activate Activate data points
%
% This method activates data points.  Only data clouds from active points
% are used during fit analysis.  
%    >> object=activate(object,index);
% Data points are referenced in the order they were added.
%
% See also CloudFitXY, deactivate, summarize
%

%
% created October 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=activate(object,index)

% handle input
assert(nargin>1,'ERROR: insufficient number of inputs');
if strcmpi(index,'all')
    index=1:object.NumberClouds;
end

valid=1:object.NumberClouds;
for k=1:numel(index)
    assert(any(index(k)==valid),'ERROR: invalid index');
end

% active requested clouds
object.ActiveClouds(index)=true;

end