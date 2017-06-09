function setChannel(object,value)

assert(isstruct(value),'ERROR: invalid channel setting');

for n=1:numel(value)
    %
    temp=value(n).Display;
    try
        temp=logical(temp);
    catch
        error('RROR: invalid display value');
    end
    command=sprintf('CHANNEL%d:DISPLAY %d',n,temp);
    fwrite(object.VISA,command);
    %
    assert(strcmpi(value(n).Coupling,'AC') || strcmpi(value(n).Coupling,'DC'),...
        'ERROR: invalid coupling type');
    if strcmp(value(n).Impedance,'50')
        value(n).Impedance='50 ohm';
    end
    assert(strcmpi(value(n).Impedance,'50 ohm') || strcmpi(value(n).Impedance,'HIGH'),...
        'ERROR: invalid impedance value');
    switch object.System.Class
        case 'Infiniium'
            temp=upper(value(n).Coupling);
            if strcmpi(value(n).Impedance,'50 ohm')
                temp=sprintf('%s50',temp);
            end
            command=sprintf('CHANNEL%d:INPUT %s',n,temp);
        case 'InfiniiScope'
            % under construction
    end    
    fwrite(object.VISA,command);
    % 
    temp=value(n).Offset;
    assert(isnumeric(temp) && isscalar(temp),...
        'ERROR: invalid offset value');
    command=sprintf('CHANNEL%d:OFFSET %g',n,temp);
    fwrite(object.VISA,command)
    %
    temp=value(n).Scale;
    assert(isnumeric(temp) && isscalar(temp) && (temp > 0),...
        'ERROR: invalid scale value');
    command=sprintf('CHANNEL%d:SCALE %g',n,temp);
    fwrite(object.VISA,command)    
end

end