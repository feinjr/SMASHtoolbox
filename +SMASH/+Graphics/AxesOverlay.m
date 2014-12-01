% AxesOverlay : Overlay two axis objects
%
%
function func=AxesOverlay(ax1,ax2)

fig=figure('Color',[1 1 1]);

ax(1)=copyobj(ax1,fig);
ax(2)=copyobj(ax2,fig);
set(ax,'Color','none','Box','off');

linkaxes(ax,'x');

set(ax(2),'YAxisLocation','right','XAxisLocation','top','XtickLabel','');