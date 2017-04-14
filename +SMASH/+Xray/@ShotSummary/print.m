function [ object ] = print( object )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

name = fieldnames(object);

for i = 1:length(name)
    fprintf('%20s  :  ',name{i})
    value = object.(name{i});
    
    units = '';
    switch name{i}
        case 'FillPressure'
            units = '[PSI]';
        case 'LinerDimensions'
            units = '[cm]';
            temp = sprintf('IR = %1.4f, OR = %1.4f ', value(1), value(2));
            value = temp;
        case 'Cushions'
            temp = sprintf('Top : %s, Bottom : %s ', value{1}, value{2});
            value = temp;
        case 'LinerCoating'
            if isempty(value)
                temp = 'none';
            else
               temp = sprintf('%3.2f um %s', value{1}, value{2});
            end
            value = temp;
        case 'ImplodingHeight'
            units = '[cm]';
        case 'FillTemperature'
            units = '[K]';
        case 'FieldStrength'
            units = '[T]';
        case 'LaserEnergy'
            units = '[J]';
        case 'WindowThickness'
            units = '[um]';
        case 'WindowOffset'
            units = '[cm]';
    end
    
    if isscalar(value)
        fprintf('%s',num2str(value))
    elseif ischar(value)
        fprintf('%s',value)
    else
        fprintf('')
    end        
        
    fprintf('%s\n',units)
end
end

