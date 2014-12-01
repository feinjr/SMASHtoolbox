% Usage:
%   >> h=object.edit_check(label,minwidth)
% label is a cell array of strings (label + button)
% minwidth defines the minimum button width in characters (optional).

function varargout=edit_button(object,label,minwidth)

% handle input
if (nargin<2) || isempty(label)
    label={'Label: ',' button '};
end

if (nargin<3) || isempty(minwidth)
    minwidth=0;
end

% error checking
verify(object);

% create block
[h,temp]=text(object,label{1},minwidth);
minwidth=max(minwidth,temp);
object.pushup(1,object.VerticalGap);
dummy=repmat('M',[1 minwidth]);
h(end+1)=local_uicontrol(object,'Style','edit','HorizontalAlignment','left',...
    'String',dummy);
object.Controls(end+1)=h(end);
set(h(end),'String','');
pos=get(h(end),'Position');
x0=pos(1)+pos(3)+object.HorizontalGap;
ym=pos(2)+pos(4)/2;
dummy=repmat('M',[1 numel(label{2})]);
h(end+1)=local_uicontrol(object,'Style','pushbutton','String',dummy,...
    'HorizontalAlignment','center');
object.Controls(end+1)=h(end);
set(h(end),'String',label{2});
pos=get(h(end),'Position');
pos(1)=x0;
pos(2)=ym-pos(4)/2;
set(h(end),'Position',pos);
pushup(object,2);
make_room(object);

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end