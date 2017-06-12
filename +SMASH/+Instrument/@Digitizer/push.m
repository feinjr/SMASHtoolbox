% push Push calibration files
function push(object)

%warning('This method pushes to a local subdirectory (for now)');

% manage multiple digitizers
if numel(object) > 1
    for n=1:numel(object)
        push(object(n));
    end
    return
end

% verify digitizer class
switch object.System.Class
    case 'Infiniium'
        % OK
    otherwise
        error('ERROR: %s class digitizers do not offer calibration push',...
            object.System.Class);
end

% single digitizer
local=sprintf('%s-%s',...
    object.System.ModelNumber,object.System.SerialNumber);

if ~exist(local,'dir')
    error('Local calibration directory not found');
end

remote=[repmat(filesep,[1 2]) object.System.Address filesep 'Infiniium'];

%%
fprintf('Backing up remote calibration data for %s\n',local);
backup=fullfile(remote,'backup');
if exist(backup,'dir')
    command=sprintf('powershell "del -force -recurse %s | out-null"',backup);
    system(command);
end
command=sprintf('powershell "mkdir %s | out-null"',backup);
system(command);

filename='license.dat';
target=fullfile(remote,'backup',filename);
source=fullfile(remote,filename);
command=sprintf('powershell "copy -force %s %s | out-null"',source,target);
system(command);

filename='cal';
target=fullfile(remote,'backup',filename);
source=fullfile(remote,filename);
command=sprintf('powershell "copy -force -recurse %s %s | out-null"',source,target);
system(command);

%%
fprintf('Pushing calibration data for %s\n',local);
remote=[repmat(filesep,[1 2]) object.System.Address filesep 'Infiniium'];
%remote=fullfile(pwd,'Infiniium');

fprintf('\t License file...');
filename='license.dat';
target=fullfile(remote,filename);
source=fullfile(local,filename);
command=sprintf('powershell "copy -force %s %s | out-null"',source,target);
system(command);
fprintf('done\n');

fprintf('\t Calibration directory...');
filename='cal';
target=fullfile(remote,filename);
source=fullfile(local,filename);
command=sprintf('powershell "copy -force -recurse %s %s | out-null"',source,target);
system(command);
fprintf('done\n');

end