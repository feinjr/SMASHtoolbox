% loadSMASH Make toolbox items available to MATLAB
%
% This function makes items from the SMASH toolbox available to MATLAB.
%
% Toolbox programs are added to the MATLAB path.
%     >> loadSMASH -program name % specific program
%     >> loadSMASH -program name1 name2 % multiple programs
%     >> loadSMASH -program * % all programs
% Programs can be loaded and called from the command window: 
%     >> loadSMASH -program SIRHEN % load SIRHEN program onto path
%     >> SIRHEN % launch SIRHEN program
% or inside functions.  Programs loaded in one workspace are available to
% all workspaces and remain on the MATLAB path throughout the current
% session (unless manually removed).
%
% Toolbox package examples can be copied to the current directory.
%     >> loadSMASH -example name % specific package examples
%     >> loadSMASH -example * % all examples
% Examples should be copied from the toolbox before execution. 
%
% Due to a MATLAB bug, this function cannot manage toolbox packages.  To
% access packages in SMASH, use dot notation:
%     >> SMASH.(package_name).(function_name)(...) % absolute function name
% or import the package into the workspace.
%     >> import SMASH.(package_name).(function_name);
%     >> function_name(...) % imported function name
% Note that imports are workspace specific!  Packages loaded into the base
% workspaced are not automatically available in function workspaces and
% vice versa.
%
% Toolbox Java directories are added to the dynamic Java path.
%     >> loadSMASH -java name % specific directory
%     >> loadSMASH -java name1 name2 % multipple directories
%     >> loadSMASH -java * % all directories
%
% By default, this function displays items being added in the command
% window.  This behavior can be controlled with the silent/verbose options.
%     >> loadSMASH -verbose ... % display items
%     >> loadSMASH -silent ...  % suppress item display 
%
% See also SMASHtoolbox
%

% Toolbox packages are added to the base workspace.
%    >> loadSMASH -package name % specific package
%    >> loadSMASH -package name1 name2 % multiple packages
%    >> loadSMASH -package * % all packages

%
% created January 13, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=loadSMASH(varargin)

% manage input
verbose=true;
mode='';
name={};
while numel(varargin)>0
    switch varargin{1}
        case '-verbose'
            verbose=true;
            varargin=varargin(2:end);
        case '-silent'
            verbose=false;
            varargin=varargin(2:end);
        case {'-program','programs','-java','-example'}
            assert(isempty(mode),'ERROR: mode conflict detected');
            mode=varargin{1};
            varargin=varargin(2:end);
            while numel(varargin)>0
                if varargin{1}(1)=='='
                    break
                end
                name{end+1}=varargin{1}; %#ok<AGROW>
                varargin=varargin(2:end);
            end             
        case '-package'
            error('ERROR: package load not currently supported');
        otherwise
            error('ERROR: invalid input detected');
    end
end
assert(~isempty(mode),'ERROR: no mode specified');
assert(~isempty(name),'ERROR: no names specified');

% load named directories
switch mode
    case {'-program' '-programs'}
        loadProgram(name,verbose);
    case '-example'
        loadExample(name,verbose);
%     case '-package'
%         %loadPackage(name,verbose);
%         % look at package directory
%         local=mfilename('fullpath');
%         [local,~]=fileparts(local);
%         local=fullfile(local,'+SMASH');
%         list=scanDirectory(local,'package');        
%         % load requested program(s)
%         if (numel(name)==1) && strcmp(name{1},'*')
%             name=list;
%         end        
%         N=numel(name);
%         %tempfile=sprintf('%f',now);
%         %tempfile=strrep(tempfile,'.','_');
%         %tempfile=sprintf('TemporaryScript_%s.m',tempfile);
%         %fid=fopen(tempfile,'w+');
%         for k=1:N
%             test=cellfun(@(x) strcmp(x,name{k}),list);
%             match=find(test,1);
%             if isempty(match)
%                 warning('SMASHtoolbox:package',...
%                     'Package %s not found in SMASH toolbox',name{k});
%             else
%                 command=sprintf('import(''SMASH.%s.*'')',name{k});
%                 %fig=figure('Visible','off');               
%                 %set(fig,'CloseRequestFcn',command);
%                 %evalin('base',command);
%                 evalin('caller',command);
%                 %fprintf(fid,'import(''SMASH.%s.*'')\n',name{k});
%                 % do something
%                 if verbose
%                     fprintf('Importing the %s package\n',name{k});
%                 end
%                 %close(fig);
%             end
%         end
%         %fclose(fid);
%         %evalin('base',sprintf('run(''%s'')',tempfile));
%         %delete(tempfile);
%         import
    case '-java'
        loadJava(name,verbose);
end

if nargout>0
    varargout{1}=name;
end

end

%%
function loadProgram(name,verbose)

% look at program directory
local=mfilename('fullpath');
[local,~]=fileparts(local);
local=fullfile(local,'programs');
list=scanDirectory(local);

% load requested program(s)
if (numel(name)==1) && strcmp(name{1},'*')
    name=list;
end

N=numel(name);
for k=1:N
    test=cellfun(@(x) strcmp(x,name{k}),list);
    match=find(test,1);
    if isempty(match)       
        warning('SMASHtoolbox:program',...
            'Program %s not found in SMASH toolbox',name{k});
    else
        addpath(fullfile(local,name{k}));
        if verbose
            fprintf('Adding %s to the MATLAB path\n',name{k});
        end
    end
end

end

function loadExample(name,verbose)

% look at program directory
local=mfilename('fullpath');
[local,~]=fileparts(local);
local=fullfile(local,'examples');
list=scanDirectory(local);

% verify target directory
[master,~]=fileparts(local);
target=pwd;
if strfind(target,master)
    error('ERROR: examples cannot be loaded here');
end

target=fullfile(target,'examples');
if exist(target,'dir')
    rmdir(target,'s');
end
mkdir(target);

% load requested example(s)
if (numel(name)==1) && strcmp(name{1},'*')
    name=list;
end

N=numel(name);
for k=1:N
    test=cellfun(@(x) strcmp(x,name{k}),list);
    match=find(test,1);
    if isempty(match)       
        warning('SMASHtoolbox:example',...
            'Example directory %s not found in SMASH toolbox',name{k});
    else
        source=fullfile(local,name{k});
        try
            copyfile(source,fullfile(target,name{k}));
        catch
            mkdir(fullfile(target,name{k}));
        end
        if verbose
            fprintf('Copying %s examples \n',name{k});
        end
    end
end

end

%%
% function loadPackage(name,verbose)
% 
% % look at package directory
% local=mfilename('fullpath');
% [local,~]=fileparts(local);
% local=fullfile(local,'+SMASH');
% list=scanDirectory(local,'package');
% 
% % load requested program(s)
% if (numel(name)==1) && strcmp(name{1},'*')
%     name=list;
% end
% 
% N=numel(name);
% for k=1:N
%     test=cellfun(@(x) strcmp(x,name{k}),list);
%     match=find(test,1);
%     if isempty(match)       
%         warning('SMASHtoolbox:package',...
%             'Package %s not found in SMASH toolbox',name{k});
%     else
%         import(sprintf('SMASH.%s.*',name{k}));
%         % do something
%         if verbose
%             fprintf('Importing the %s package\n',name{k});
%         end
%     end
% end
% 
% end

%%
function loadJava(name,verbose)

% look at java directory
local=mfilename('fullpath');
[local,~]=fileparts(local);
local=fullfile(local,'java');
list=scanDirectory(local);

% load requested program(s)
if (numel(name)==1) && strcmp(name{1},'*')
    name=list;
end

N=numel(name);
for k=1:N
    test=cellfun(@(x) strcmp(x,name{k}),list);
    match=find(test,1);
    if isempty(match)       
        warning('SMASHtoolbox:java',...
            'Java directory %s not found in SMASH toolbox',name{k});
    else
        if verbose
            fprintf('Adding %s to the dynamic Java path\n',name{k});
        end
        javaaddpath(fullfile(local,name{k}));       
    end
end

end

%% utility function
function list=scanDirectory(dirname,mode)

if (nargin<2) || isempty(mode)
    mode='standard';
end

list={};
filename=dir(dirname);
for k=1:numel(filename)
    if ~filename(k).isdir % non-directory
        continue
    elseif filename(k).name(1)=='.' % hidden directory
        continue
    elseif strcmp(mode,'standard') && (filename(k).name(1) ~='+') % package directory
        list{end+1}=filename(k).name; %#ok<AGROW>
    elseif strcmp(mode,'package')  && (filename(k).name(1) =='+') % standard directory
        list{end+1}=filename(k).name(2:end); %#ok<AGROW>
    end
end

end