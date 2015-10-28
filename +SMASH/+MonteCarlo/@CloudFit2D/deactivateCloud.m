% deactivateCloud Deactivate cloud(s)
%
% This method deactivates clouds in a CloudFit2D object.
%    >> object=deactivate(object,index);
% Data points are referenced in the order they were added.
%
% Only data clouds from active points are used during fit analysis.
%
% See also CloudFit2D, activateCloud
%

%
% created October 28, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=deactivateCloud(object,index)

% manage input
assert(nargin>1,'ERROR: insufficient number of inputs');
if strcmpi(index,'all')
    index=1:object.NumberClouds;
end

valid=1:object.NumberClouds;
for k=1:numel(index)
    assert(any(index(k)==valid),'ERROR: invalid index');
end

% process request
active=object.ActiveClouds;
keep=true(size(active));

index=unique(index);
for n=1:numel(index)
    keep(active==index(n))=false;
end
object.ActiveClouds=active(keep);

% update weights
object=calculateWeights(object);

end