% loadSMASH Make toolbox items available to MATLAB
%
% This function makes items from the SMASH toolbox available to MATLAB.
% Toolbox programs are added to the MATLAB path.
%     >> loadSMASH -program name % specific program
%     >> loadSMASH -program name1 name2 % multiple programs
%     >> loadSMASH -program * % all programs
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
        case {'-program','-java'}
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
        otherwise
            error('ERROR: invalid input detected');
    end
end
assert(~isempty(mode),'ERROR: no mode specified');
assert(~isempty(name),'ERROR: no names specified');

% load named directories
switch mode
    case '-program'
        loadProgram(name,verbose);
    case '-java'
        loadJava(name,verbose);        
end

if nargout>0
    varargout{1}=name;
end

end

function list=scanDirectory(dirname)

list={};
filename=dir(dirname);
for k=1:numel(filename)
    if ~filename(k).isdir
        continue
    elseif filename(k).name(1)=='.' % hidden directory
        continue
    elseif filename(k).name(1)=='+' % package directory
        continue
    end
    list{end+1}=filename(k).name; %#ok<AGROW>
end

end

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