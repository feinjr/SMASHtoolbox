% REPLACE Replace data values in an object
%
% UNDER CONSTRUCTION
% 
% See also Image
%

%
% created November 19, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=replace(object,array1,array2,value)

% handle input
assert(nargin==4,'ERROR: invalid number of inputs');

% interpret array1 input
if islogical(array1) && (numel(array1)==numel(object.Grid1))    
    % valid request 
elseif strcmpi(array1,'all')
    array1=true(size(object.Grid1));
elseif isnumeric(array1) && (numel(array1)==2)
    array1=(object.Grid1>=array1(1)) & (object.Grid1<=array1(2));
else
    error('ERROR: invalid replacement array');    
end

% interpret array2 input
if islogical(array2) && (numel(array2)==numel(object.Grid2))    
    % valid request 
elseif strcmp(array2,'all')
    array2=true(size(object.Grid2));
elseif isnumeric(array2) && (numel(array2)==2)
    array2=(object.Grid2>=array2(1)) & (object.Grid2<=array2(2));
else
    error('ERROR: invalid replacement array');    
end

object.Data(array2,array1)=value;

object=updateHistory(object);

end