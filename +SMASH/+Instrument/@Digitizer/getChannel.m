function value=getChannel(object)

communicate(object);

N=4;
for n=1:N
    local=struct();
    %
    command=sprintf('CHANNEL%d:DISPLAY?',n);
    fwrite(object.VISA,command);
    temp=fscanf(object.VISA);
    local.Display=logical(sscanf(temp,'%g'));
    %
    switch object.System.Class
        case 'Infiniium'
            command=sprintf('CHANNEL%d:INPUT?',n);
            fwrite(object.VISA,command);
            temp=strtrim(fscanf(object.VISA));
            local.Coupling=temp(1:2);
            temp=temp(3:end);
            if isempty(temp)
                local.Impedance='HIGH';
            else
                local.Impedance='50 ohm';
            end
        case 'InfiniiScope'
            % under construction
    end
    %
    command=sprintf('CHANNEL%d:OFFSET?',n);
    fwrite(object.VISA,command);
    temp=fscanf(object.VISA);
    local.Offset=sscanf(temp,'%g');
    %
    command=sprintf('CHANNEL%d:SCALE?',n);
    fwrite(object.VISA,command);
    temp=fscanf(object.VISA);
    local.Scale=sscanf(temp,'%g');
    %
    %command=sprintf('CHANNEL%d:LABEL?',n);
    %fwrite(object.VISA,command);
    %temp=fscanf(object.VISA);
    %local.Label=strtrim(temp);
    %local.Label=local.Label(2:end-1);
    %
    if n==1
        value=repmat(local,[4 1]);
    else
        value(n)=local;
    end
end

end