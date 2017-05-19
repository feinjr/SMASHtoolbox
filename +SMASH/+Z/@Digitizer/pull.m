% pull Pull calibration files
function pull(object)

% manage multiple digitizers
if numel(object) > 1
    for n=1:numel(object)
        pull(object(n));
    end
    return
end

% single digitizer
local=sprintf('%s-%s',...
    object.System.ModelNumber,object.System.SerialNumber);
if exist(local,'dir')
    command=sprintf('powershell "del -force -recurse %s | out-null"',local);
    system(command);
end
mkdir(local);

fprintf('Pulling calibration data for %s\n',local);
remote=[repmat(filesep,[1 2]) object.System.Address filesep 'Infiniium'];

fprintf('\t License file...');
filename='license.dat';
source=fullfile(remote,filename);
target=fullfile(local,filename);
command=sprintf('powershell "copy %s %s | out-null"',source,target);
system(command);
fprintf('done\n');

fprintf('\t Calibration directory...');
filename='cal';
source=fullfile(remote,filename);
target=fullfile(local,filename);
command=sprintf('powershell "copy -recurse %s %s | out-null"',source,target);
system(command);
fprintf('done\n');

end