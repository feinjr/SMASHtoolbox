% localhost Determine local IP address
%
% This function determines the local IP address, regardless of the current
% operating system.
%    address=localhost();
%
% See also System, listIP4, ping
%

%
% created April 26, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function address=localhost()

if ispc
    [~,result]=system('ping -n 1 localhost');
    result=sscanf(result,'%*s %s',1);
    command=sprintf('ping -n 1 %s',strtrim(result));
    [~,result]=system(command);
    result=sscanf(result,'%*s %*s %s',1);
    address=result(2:end-1);
else
    [~,result]=system('bash -c ''hostname''');
    command=sprintf('bash -c ''ping -c 1 %s'' ',strtrim(result));
    [~,result]=system(command);
    result=sscanf(result,'%*s %*s %s',1);
    address=result(2:end-2);
end

end