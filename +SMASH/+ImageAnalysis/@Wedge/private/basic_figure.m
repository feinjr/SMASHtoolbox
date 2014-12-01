% basic_figure: create a basic figure for imaging visualization
%

% created October 8, 2012 by Daniel Dolan (Sandia National Laboratories)
% revised May 29, 2013 by Daniel Dolan
%    -added support for existing figures
function h=basic_figure(target)

% handle input
if (nargin<1) 
    target=[];
end

% create graphic objects
if isempty(target)
    h.figure=figure;
else
    h.figure=target;
    clf(target);
end
set(h.figure,'DockControls','off',...
    'ToolBar','figure','MenuBar','none');
color=get(h.figure,'Color');

h.panel=uipanel('Parent',h.figure,'Tag','GraphicPanel',...
    'BorderType','none','BackgroundColor',color,...
    'Units','normalized','Position',[0 0 1 1]);  

% tweak the figure menu
hb=findall(h.figure,'Type','uitoolbar');
hb=findall(hb);
hb=hb(2:end);
drop=true(size(hb));
for n=1:numel(hb)
    tag=lower(get(hb(n),'Tag'));
    if strfind(tag,'zoom')
        drop(n)=false;
    elseif strfind(tag,'pan')
        drop(n)=false;
    elseif strfind(tag,'cursor')
        drop(n)=false;
    elseif strfind(tag,'save')
        drop(n)=false;
    end
end
set(hb(drop),'Visible','off');
set(hb,'Separator','off');

end