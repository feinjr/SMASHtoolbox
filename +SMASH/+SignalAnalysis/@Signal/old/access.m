% access method for Signal objects
%
% This function accesses the region of interest defined by the "limit"
% method, which is extracted as needed to conserve memory.  If no region
% has been defined, the outputs are equivalent to the object's Grid and
% Data properties.
%
% Usage:
%    >> [Grid,Data]=access(object);
%

% created October 2, 2013 by Daniel Dolan (Sandia National Laboratories)
function varargout=access(object)

% access data
if strcmp(object.LimitIndex,'all')
    x=object.Grid;
    y=object.Data;
else
    x=object.Grid(object.LimitIndex);
    y=object.Data(object.LimitIndex);
end

% handle output
if nargout>=1
    varargout{1}=x;
end

if nargout>=2
    varargout{2}=y;
end

end