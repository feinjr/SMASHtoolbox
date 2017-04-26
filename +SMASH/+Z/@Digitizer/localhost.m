function machine=localhost()

[~,report]=system('ipconfig');
start=strfind(report,'IPv4 Address');
report=report(start:end);
while numel(report)>0
    address=sscanf(report,':%d.%d.%d.%d',4);
    if isempty(address)
        report=report(2:end);
        continue
    end
    break
end
machine=sprintf('%d.',address);
machine=machine(1:end-1);


end