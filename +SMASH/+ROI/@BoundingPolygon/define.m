% UNDER CONSTRUCTION
%

%

function object=define(object,data)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

% place data in object
if isempty(data)
    % do nothing   
else
    assert(size(data,2)==2,'ERROR: invalid data');
end

object.Data=data;

end