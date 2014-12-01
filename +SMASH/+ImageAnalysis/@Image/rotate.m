% ROTATE Rotate Image objects
%
% Usage:
%   >> object=rotate(object,direction)
%   >> object=rotate(object,'left'); % rotate 90 degrees to the left
%   ('counter-clockwise')
%   >> object=rotate(object,'right'); % rotate 90 degrees to the right
%   ('clockwise')
%   >> object=rotate(object,angle); % rotate by specified angle degrees
%
% See also IMAGE, flip

% created July 27, 2012 by Daniel Dolan (Sandia National Laboratories)
% revised December 28, 2012 by Daniel Dolan
%   -added rotation by a specified angle
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
%
function object=rotate(object,argument)

% handle input
if (nargin<2) || isempty(argument)
    argument=questdlg('Choose rotation direction','Rotate direction',...
        ' left ',' right ',' cancel ',' left ');
    argument=strtrim(argument);
    if strcmp(argument,'cancel')
        return
    end   
end

% apply rotation
if isnumeric(argument)
    object.Data=twist(object.Data,argument);
else
    switch lower(argument)
        case {'left','counter-clockwise','counterclockwise'}          
            object.Data=transpose(object.Data);
            object=flip(object,'Grid2');
        case {'right','clockwise'}            
            object=flip(object,'Grid2');
            object.Data=transpose(object.Data);            
        otherwise
            error('ERROR: invalid input argument for rotation');
    end
    x=object.Grid1;
    object.Grid1=transpose(object.Grid2);
    object.Grid2=transpose(x);
    label=object.Grid1Label;
    object.Grid1Label=object.Grid2Label;
    object.Grid2Label=label;
end

object.ObjectHistory=object.ObjectHistory(1:end-1);
object=updateHistory(object);
end