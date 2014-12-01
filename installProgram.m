% installProgram Install SMASH toolbox program(s)
%
% This function installs SMASH toolbox programs on the MATLAB path.
% Specific programs can be installed by name:
%     >> installProgram(name); % install one program
%     >> installProgram(name1,name2,...); % install multiple programs
% or all at once.
%     >> installPogram; % install all programs
%
% See also SMASHtoolbox
%

%
% created December 1, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function installProgram(varargin)

% look at programs directory
local=mfilename('fullpath');
[local,~]=fileparts(local);
local=fullfile(local,'programs');

program={};
filename=dir(local);
for k=1:numel(filename)
    if ~filename(k).isdir
        continue
    elseif filename(k).name(1)=='.'
        continue
    end
    program{end+1}=filename(k).name; %#ok<AGROW>
end


% handle input
if nargin==0
    varargin=program;
end

% process requests
for k=1:numel(varargin)
    test=cellfun(@(x) strcmp(x,varargin{k}),program);
    match=find(test,1);
    if isempty(match)       
        warning('SMASHtoolbox:program',...
            'program %s not found in SMASH toolbox',varargin{k});
    else
        addpath(fullfile(local,varargin{k}));
    end
end


end