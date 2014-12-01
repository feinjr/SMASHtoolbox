function varargout=table(object,label,minwidth,rows)

% handle input
if (nargin<2) || isempty(label)
    label={' Column 1 ' ' Column 2 '};
end
assert(iscell(label),'ERROR: label input must be a cell array');
columns=numel(label);

if (nargin<3) || isempty(minwidth)
    minwidth=0;
end
assert(isnumeric(minwidth),'ERROR: invalid minwidth');
if numel(minwidth)==1
    minwidth=repmat(minwidth,[1 columns]);
end
assert(numel(minwidth)==columns,'ERROR: inconsistent input sizes');

if (nargin<3) || isempty(rows)
    rows=10;
end

% error checking
verify(object);

% create block
h=nan(1,columns+1);
columnwidth=cell(1,columns);
totalwidth=0;
for n=1:columns
    dummy=max(numel(label{n}),minwidth(n));
    dummy=repmat('M',[1 dummy]);
    h(n)=local_uicontrol(object,'Style','text','String',dummy,...
        'HorizontalAlignment','left');
    position=get(h(n),'Position');
    if n==1
        pushup(object);
        pushup(object,1,object.VerticalGap);
        x0=position(1);
        rowheight=position(4);
    end
    position(1)=x0;
    set(h(n),'Position',position);
    columnwidth{n}=position(3);
    x0=x0+columnwidth{n};
    set(h(n),'String',label{n});   
    object.Controls(end+1)=h(n);
    totalwidth=totalwidth+columnwidth{n};
end

h(end)=uitable('RowName','','ColumnName','',...
    'ColumnWidth',columnwidth);
position=get(h(end),'Position');
extent=get(h(end),'Extent');
position(3)=totalwidth;
position(4)=rows*rowheight;
set(h(end),'Position',position);
object.pushup;

object.make_room;

data=cell(rows,columns);
set(h(end),'Data',data);

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end