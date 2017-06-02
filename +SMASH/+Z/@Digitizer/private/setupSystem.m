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

%result.ModelClass

start=stop(2)+1;
result.SerialNumber=query(start:stop(3)-1);

start=stop(3)+1;
result.SoftwareVersion=query(start:stop(4)-1);

end