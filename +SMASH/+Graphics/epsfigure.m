% EPSFIGURE Convert a MATLAB figure to an *.eps file
%
%
%    >> epsfigure(filename);
%
% UNDER CONSTRUCTION


function epsfigure(filename,varargin)

warning('SMASH:Graphics',...
    'This function is obosete and will be removed in the future');
fprintf('Use the printFigure function instead\n');

% handle input
assert(nargin>0,'ERROR: no file name given');

N=numel(varargin);
assert(rem(N,2)==0,'ERROR: unmatched name/value pair');
option=struct('renderer','painters','resolution',600,'target',[]);
for n=1:2:N
    name=lower(varargin{n});
    assert(isfield(option,name),'ERROR: invalid option name');
    option.(name)=varargin{n+1};
end

if isempty(option.target)
    option.target=gcf;
elseif ishandle(option.target) % child handle (axes, line, etc.)
    option.target=ancestor(option.target,'figure');
else
    error('ERROR: invalid target handle');
end

if isnumeric(option.resolution)
    option.resolution=sprintf('-r%g',resolution);
end

% prepare target figure
paperpositionmode=get(option.target,'PaperPositionMode');
set(option.target,'PaperPositionMode','auto');

renderer=get(option.target,'Renderer');
set(option.target,'renderer','painters');

% print figure to file
print('-depsc2','-loose',option.resolution,filename);

% restore target figure settings
set(option.target,'PaperPositionMode',paperpositionmode);
set(option.target,'Renderer',renderer);

end