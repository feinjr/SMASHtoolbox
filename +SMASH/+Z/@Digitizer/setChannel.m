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
    switch lower(value(n).Input)
        case {'dc' 'dc50' 'ac' 'ac50'}
            % valid choices
        otherwise
            error('ERROR: invalid input value');
    end
    command=sprintf('CHANNEL%d:INPUT %s',n,value(n).Input);
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
    %
    %temp=value(n).Label;
    %assert(ischar(temp),'ERROR: invalid label value');
    %if temp(1) ~= '"'
    %    temp=['"' temp '"']; %#ok<AGROW>
    %end
    %command=sprintf('CHANNEL%d:LABEL %s',n,temp);
    %fwrite(object.VISA,command)
end

end