%% example A: fudamental records
clc;
filename='SDAexampleA.sda';
archive=SMASH.FileAccess.SDAfile(filename,'overwrite');

insert(archive,'entry 1',zeros(3,4));
describe(archive,'entry 1','A 3x4 array of zeros');

insert(archive,'entry 2','');
describe(archive,'entry 2','An empty character array');

insert(archive,'entry 3',true);
describe(archive,'entry 3','A 1x1 logical array');

insert(archive,'entry 4',@sin);
describe(archive,'entry 4','A simple function handle');

command=sprintf('h5disp(''%s'')',filename);
result=evalc(command);
k=strfind(result,'Group ''/''');
result=strtrim(result(k(1):end));
SMASH.FileAccess.writeFile('SDAexampleA.txt','%s',result);

%% example B: cell arrays
clc;
filename='SDAexampleB.sda';
archive=SMASH.FileAccess.SDAfile(filename,'overwrite');

array={single(zeros(3,4)) '' true {@sin @cos}};
insert(archive,'array',array);
describe(archive,'array','Nested cell array example');

command=sprintf('h5disp(''%s'')',filename);
result=evalc(command);
k=strfind(result,'Group ''/''');
result=strtrim(result(k(1):end));
SMASH.FileAccess.writeFile('SDAexampleB.txt','%s',result);

%% example C: structure arrays
clc;
filename='SDAexampleC.sda';
archive=SMASH.FileAccess.SDAfile(filename,'overwrite');

data=struct('entry_1',zeros(3,4));
data.functions={@sin @cos};
data.parameter=struct('offset',0,'amplitude',1);

%data(2)=data; % array testing
%data=repmat(data,[2 3]); % array testing
insert(archive,'array',data);
describe(archive,'array','Nested structure array example');

command=sprintf('h5disp(''%s'')',filename);
result=evalc(command);
k=strfind(result,'Group ''/''');
result=strtrim(result(k(1):end));
SMASH.FileAccess.writeFile('SDAexampleC.txt','%s',result);