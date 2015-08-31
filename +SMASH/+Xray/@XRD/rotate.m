% UNDER CONSTRUCTION

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
    % density increases to the horizontal position
    temp=mean(object.Measurement,'Grid2');
    param=polyfit(temp.Grid,temp.Data,1);
    if param(1)<0
        object.Measurement=flip(object.Measurement,'Grid1');
    end
    % density increases with vertical position
    temp=mean(object.Measurement,'Grid1');
    param=polyfit(temp.Grid,temp.Data,1);
    if param(1)<0
        object.Measurement=flip(object.Measurement,'Grid2');
    end
else
    object.Measurement=rotate(object.Measurement,value);
end

end