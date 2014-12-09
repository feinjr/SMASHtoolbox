function update(object)

assert(strcmp(object.Status,'alive'),'ERROR: dead objects cannot be updated');

% verify (x,y) data
x=object.XData(:);
y=object.YData(:);
if numel(x)==numel(y)
    % do nothing
elseif numel(x)==1
    x=repmat(x,[numel(y) 1]);
elseif numel(y)==1
    y=repmat(y,[numel(x) 1]);
else
    error('ERROR: incompatible (x,y) data');
end

if numel(x)>0
    set(object.Group,'Visible','on');
else
    set(object.Group,'Visible','off');
end

% apply data
h=get(object.Group,'Children');
h=h(end:-1:1); 

set(h,'XData',x);
set(h,'YData',y);

set(h(1),'Color',object.BackgroundColor);
set(h(2),'Color',object.ForegroundColor);

set(h,'LineWidth',object.LineWidth);

end