function result=setupSystem(query,address)

result.Address=address;

stop=strfind(query,',');
if numel(stop) < 4
    stop(4)=numel(query);
end

start=1;
result.Company=query(start:stop(1)-1);

start=stop(1)+1;
result.ModelNumber=query(start:stop(2)-1);

start=stop(2)+1;
result.SerialNumber=query(start:stop(3)-1);

start=stop(3)+1;
result.SoftwareVersion=query(start:stop(4)-1);
temp=sscanf(result.SoftwareVersion,'%d.%d.%d');
major=temp(1);
minor=temp(2);
if (major < 5) || (minor < 50)
    warning('This class requires Infiniium version 5.50 or later');
    fprintf('\tConsider upgrading the %s (SN %s) located at %s\n',...
        result.ModelNumber,result.SerialNumber,address);
end

end