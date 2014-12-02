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
% modified December 2, 2014 by Tommy Ao (Sandia National Laboratories)
%   -fixed Grids to match left and right rotations 
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
    x=object.Grid1;
    y=object.Grid2;
    xlabel=object.Grid1Label;
    ylabel=object.Grid2Label;
    switch lower(argument)
        case {'left','counter-clockwise','counterclockwise'}          
            object.Data=transpose(object.Data);
            object=flip(object,'Grid2');
            x=x(end:-1:1);
        case {'right','clockwise'}            
            object=flip(object,'Grid2');
            object.Data=transpose(object.Data);
            y=y(end:-1:1);
        otherwise
            error('ERROR: invalid input argument for rotation');
    end
    object.Grid1=transpose(y);
    object.Grid2=transpose(x);
    object.Grid1Label=ylabel;
    object.Grid2Label=xlabel;
end

object.ObjectHistory=object.ObjectHistory(1:end-1);
object=updateHistory(object);
end