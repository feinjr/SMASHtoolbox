function generateConfigurationReport(dig)

name=sprintf('DigitizerConfiguration_%.6g.txt',now);
fid=fopen(name,'w');
CU=onCleanup(@() fclose(fid));
fprintf(fid,'Configuration report generated %s\n',datestr(now));

if isempty(dig)
    fprintf(fid,'(No digitizers selected)\n');
else
    print(dig,fid);
end

%winopen(name);
command=sprintf('start wordpad.exe %s',fullfile(pwd,name));
system(command);