% push Push calibration files
function push(object)

warning('This method pushes to a local subdirectory (for now)');

% manage multiple digitizers
if numel(object) > 1
    for n=1:numel(object)
        push(object(n));
    end
    return
end

% single digitizer
local=sprintf('%s-%s',...
    object.System.ModelNumber,object.System.SerialNumber);

if ~exist(local,'dir')
    error('Local calibration directory not found');
end

fprintf('Pushing calibration data for %s\n',local);
%remote=[repmat(filesep,[1 2]) object.System.Address filesep 'Infiniium'];
remote=fullfile(pwd,'Infiniium');

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