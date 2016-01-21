% 
% figure2pdf 
function figure2pdf(varargin)

warning('SMASH:Graphics',...
    'This function is obosete and will be removed in the future');
fprintf('Use the printFigure function instead\n');

% handle input
assert(nargin>0,'ERROR: no file name specified');
filename=varargin{end};
[~,~,ext]=fileparts(filename);
if ~strcmpi(ext,'.pdf')
    filename=[filename '.pdf'];
end

%
fig=gcf;
previous=struct(...
    'PaperUnits',get(fig,'PaperUnits'),...
    'PaperPositionMode',get(fig,'PaperPositionMode'),...
    'PaperSize',get(fig,'PaperSize'));
units=get(fig,'Units');
pos=get(fig,'Position');
set(fig,'PaperPositionMode','auto','PaperUnits',units,'PaperSize',pos(3:4));

print('-dpdf','-painters',filename);
set(fig,...
    'PaperUnits',previous.PaperUnits,...
    'PaperPositionMode',previous.PaperPositionMode,...
    'PaperSize',previous.PaperSize);

end