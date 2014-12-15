% add Add object(s) to the group
%
% This method adds one or more BoundaryCurve objects to the group.
%     >> add(group,bound);
%     >> add(group,bound1,bound2,...);
% An empty boundary is added when no existing bounary is specified.
%     >> add(gropu);
%
% See also BoundingCurveGroup, remove
%

%
% created December 15, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function add(object,varargin)

% manage input
if nargin==1
    object.Children{end+1}=SMASH.ROI.BoundingCurve;
    return    
end

% add bounds
for n=1:numel(varargin)
    new=varargin{n};
    if isa(new,'SMASH.BoundingCurveGroup')
        object=add(object,new.Children{:});
        continue
    end
    assert(isa(new,'SMASH.ROI.BoundingCurve'),'ERROR: invalid bound');
    object.Children{end+1}=new;
end

end