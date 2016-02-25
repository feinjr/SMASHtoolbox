% extract Extract cloud variables
%
% This method extracts variables from an existing cloud to create a new
% cloud.
%    new=extract(object,variable);
% The input "variable" is an array of variable indices.  Each index must
% correspond to an exisiting variable and may only be used once per
% extraction.  Indices may be specified in any order.
%
% See also Cloud
%

%
% created February 25, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function new=extract(object,variable)

% manage input
assert(nargin>-2,'ERROR: insufficient input');

assert(isnumeric(variable),'ERROR: invalid variable index');
valid=1:object.NumberVariables;
N=numel(variable);
for n=1:N
    assert(any(variable(n)==valid),'ERROR: invalid variable index');
end
assert(numel(unique(variable))==N,'ERROR: repeated variable index');

% extract data
data=object.Data(:,variable);
new=SMASH.MonteCarlo.Cloud(data,'table');
new.VariableName=object.VariableName(variable);

% carry over settings
new.Seed=object.Seed;

if isscalar(object.GridPoints)
    new.GridPoints=object.GridPoints;    
else
    new.GridPoints=object.GridPoints(variable);
end

new.SmoothFactor=object.SmoothFactor;
new.PadFactor=object.PadFactor;
new.NumberContours=object.NumberContours;

end