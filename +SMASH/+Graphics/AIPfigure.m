% AIPfigure Create figure for AIP journals
%
% This function creates 1-2 column figures for American Institute of
% Physics journals (J. Appl. Phys, Rev. Sci. Instrum., etc.).  By default,
% single column, 10 cm tall figures are generated.
%    >> AIPfigure;
% The number of columns can be specified with an input argument.
%    >> AIPfigure(2);  % two column figure
%    >> AIPfigure(1);  % single column figure
%    >> AIPfigure([]); % single column figure
% Figure height is specified by a second input.  This input should be a
% string containing a number and unit abbreviation.
%    >> AIPfigure(...,'5in'); % 5 inch height
%    >> AIPfigure(...,'10cm'); % 10 cm height
%    >> AIPfigure(...,'50mm'); % 50 mm height
% The function's output, if requested, is the figure's graphic handle.
%    >> h=AIPfigure(...);
%

% created October 11, 2013 by Daniel Dolan (Sandia Nationa Laboratories)
function varargout=AIPfigure(numcol,height)

if (nargin<1) || isempty(numcol)
    numcol=1;
end

if (nargin<2) || isempty(height)
    height='10cm';
end

% interpret height
[value,~,~,next]=sscanf(height,'%g',1);
height=height(next:end);
unit=sscanf(height,'%s',1);
switch unit
    case 'cm'
        height=value;
    case 'mm'
        height=value/10;
    case 'in'
        height=value*2.54;
end

% create figure
fig=figure('Units','centimeters','PaperPositionMode','auto',...
    'Visible','off');

width=numcol*8.5; % cm
pos=get(fig,'Position');
pos(3)=width;
pos(4)=height;
set(fig,'Position',pos);
movegui(fig,'northeast');
set(fig,'Visible','on');

% handle output
if nargout>=1
    varargout{1}=fig;
end

end