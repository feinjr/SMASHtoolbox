% activateCloud Activate cloud(s)
%
% This method activates clouds in CloudFit2D object.  
%    >> object=activate(object,index);
% Data points are referenced in the order they were added.  To activate all
% clouds:
%    >> object=activate(object,'all');
%
% Only data clouds from active points are used during analysis.
% 
% See also CloudFit2D, deactivateCloud
%

%
%
%
function object=activateCloud(object,index)

% manage input
assert(nargin>1,'ERROR: insufficient number of inputs');
if strcmpi(index,'all')
    index=1:object.NumberClouds;
end

% process request
active=object.ActiveClouds;
valid=1:object.NumberClouds;
for k=1:numel(index)
    assert(any(index(k)==valid),'ERROR: invalid index');
    active(end+1)=index(k); %#ok<AGROW>
end

active=unique(active);
object.ActiveClouds(index)=active;

end