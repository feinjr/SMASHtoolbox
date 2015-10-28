% remove Remove cloud(s)
%
% This method removes clouds from a CloudFit2D object.
%    >> object=removeCloud(object,index);
% Clouds are referenced in the order they were added.
%
% See also CloudFit2D, addCloud
%

%
%
%
function object=removeCloud(object,index)

assert(nargin>1,'ERROR: insufficient number of inputs');
valid=1:object.NumberClouds;
keep=true(object.NumberClouds,1);
for k=1:numel(index)
    assert(any(index(k)==valid),'ERROR: invalid index');
    keep(index)=false;
end

object.CloudData=object.CloudData(keep);

active=false(object.NumberClouds,1);
active(object.ActiveClouds)=true;
active=active(keep);
object.ActiveClouds=find(active);

object.NumberClouds=numel(object.CloudData);

end