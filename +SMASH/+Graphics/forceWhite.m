% forceWhite : force white backgrounds in a figure
%
% This function forces a figure and certain objects (uipanels, axes) in
% that figure to have a white background.  Such changes allow figures
% exported to a graphic file (*.pdf, etc.) to be consistent with printing
% onto white paper.
%
% Calling the function without an input argument:
%    >> forceWhite;
% operates on the current figure.  To operate on a specific figure, pass
% the figure's handle.
%    >> forceWhite(2); % force white backgrounds in figure 2
% In each case, the following changes are applied.
%    -The figure's Color property is set to 'w'.
%    -All axes have their Color property set to 'w' unless their current
%    color is 'none' (in which case the property is left unchanged).
%    -All uipanels have their BackgroundColor property set to 'w'.
% The last change can be modified by passing a second function input.
%    >> forceWhite(...,'loose');
% 'loose' mode changes uipanel color only when it matches the original
% figure color; uipanels that did not match the figure are left unchanged.
% The default mode, 'strict', forces changes to all uipanels.
% 
%

%
% created July 15, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function forceWhite(target,mode)

% haxesndle input
if (nargin<1) || isempty(target)
    target=gcf;
end
assert(ishandle(target),'ERROR: invalid target');
target=ancestor(target,'figure');

if (nargin<2) || isempty(mode)
    mode='strict';
end
assert(strcmpi(mode,'strict') || strcmpi(mode,'loose'),...
    'ERROR: invalid mode');

% probe figure, panel, and axes objects
FigureColor=get(target,'Color');

hpanel=findobj(target,'Type','uipanel');
PanelColor=get(hpanel,'BackgroundColor');

haxes=findobj(target,'Type','axes');

% set colors to white
set(target,'Color','w');

for n=1:numel(hpanel)    
    if strcmp(mode,'strict') || all(FigureColor==PanelColor{n})
        set(hpanel(n),'BackgroundColor','w');
    end
end

for n=1:numel(haxes)
    color=get(haxes(n),'Color');
    if strcmpi(color,'none')
        continue
    end
    set(haxes(n),'Color','w');
end


end