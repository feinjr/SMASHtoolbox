% rotate Rotate measured image
%
% This method rotates step wedge measurement.  The image can be rotated by
% a specified angle (in degrees):
%     >> object=rotate(object,theta);
% or automatically.
%     >> object=rotate(object);
% Automatic rotation forces the image's longest dimension to be horiztonal,
% with increasing intensity along the horizontal/vertical grid.  NOTE:
% vertical grids increases from top to bottom by default, so auto-rotated
% images may appear inverted.
%
% See also StepWedge, view
%

%
% created August 26, 2016 by Daniel Dolan (Sandia National Laboratory)
%
function object=rotate(object,value)

% manage input
if (nargin<2) || isempty(value)
    value='auto';
end

% perform rotation
if strcmpi(value,'auto')
    % make the long side horizontal
    [Ly,Lx]=size(object.Measurement.Data);
    if Ly>Lx
        object.Measurement.Data=transpose(object.Measurement.Data);
    end
    % intensity increases to the horizontal position
    temp=mean(object.Measurement,'Grid2');
    param=polyfit(temp.Grid,temp.Data,1);
    if param(1)<0
        object.Measurement=flip(object.Measurement,'Grid1');
    end
    % intensity increases with vertical position
    temp=mean(object.Measurement,'Grid1');
    param=polyfit(temp.Grid,temp.Data,1);
    if param(1)<0
        object.Measurement=flip(object.Measurement,'Grid2');
    end
else
    object.Measurement=rotate(object.Measurement,value);
end

end