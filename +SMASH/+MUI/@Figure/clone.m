% created August 4, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised August 5, 2013 by Daniel Dolan
%   -legends and colorbars now cloned with their source axes
% revised May 15, 2014 by Daniel Dolan
%   -callbacks (button down, context, etc.) removed from cloned objects
function clone(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','Clone','ToolTipString','Clone axes to separate figure',...
            'Cdata',local_graphic('CloneIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.Clone=h;
    case 'hide'
        set(object.Button.Clone,'Visible','off');
    case 'show'
        set(object.Button.Clone,'Visible','on');
end

%%
    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        fig=object.Handle;
        if strcmpi(state,'on')
            haxes=findobj(fig,'Type','axes');
            if numel(haxes)==1
                MakeClone(haxes);
                return
            end
            set(src,'State','on');
            set(object.Handle,'Pointer','crosshair',...
                'WindowButtonUpFcn',@ButtonUp);
        end
    end

    function ButtonUp(varargin)
        haxes=get(gcbf,'CurrentAxes');
        tag=get(haxes,'Tag');
        if  strcmp(tag,'legend') || strcmp(tag,'colorbar')
            return
        end
        MakeClone(haxes);
    end

end

function MakeClone(target)

% preparations
srcfig=ancestor(target,'figure');

% copy selected axes
name=sprintf('Axes clone created %s',datestr(now));
fig=figure('Name',name);
new=copyobj(target,fig);
set(new,'Units','normalized','OuterPosition',[0 0 1 1]);

h=findall(fig,'-not','DeleteFcn','');
set(h,'DeleteFcn','');

% deal with legends
h=findobj(srcfig,'Tag','legend');
for m=1:numel(h)
   data=get(h(m),'UserData');
   if data.PlotHandle~=target
       continue
   end
   index=nan(size(data.handles));
   children=get(target,'Children');
   for n=1:numel(index)
       index(n)=find(data.handles(n)==children);
   end
   children=get(new,'Children');
   location=get(h,'Location');
   legend(children(index),data.lstrings,'Location',location);
end

% deal with colorbars
h=findobj(srcfig,'Tag','Colorbar');
if numel(h)>0
    % find target axes boundaries
    TargetUnits=get(target,'Units');
    position=get(target,'OuterPosition');
    xb=position(1)+[0 position(3)];
    yb=position(2)+[0 position(4)];
    % determine if colorbar is fully inside
    for m=1:numel(h)
        units=get(h(m),'Units');
        set(h(m),'Units',TargetUnits);
        try
            pos=get(h(m),'OuterPosition'); % pre-2014b MATLAB
            set(h(m),'Units',units);
            xc=pos(1)+pos(3)/2;
            yc=pos(2)+pos(4)/2;
            if (xc<xb(1)) || (xc>xb(2)) || (yc<yb(1)) || (yc>yb(2))
                continue % no match
            end
        catch
           if getappdata(h,'TargetAxes') ~= target % post-2014b MATLAB
               continue
           end
        end
        % create matching colorbar
        location=get(h(m),'Location');
        hc=colorbar('peer',new,'Location',location);
        % carry labels
        label=get(get(h(m),'XLabel'),'String');
        xlabel(hc,label);
        label=get(get(h(m),'YLabel'),'String');
        ylabel(hc,label);
        label=get(get(h(m),'Title'),'String');
        title(hc,label);
    end
end

% remove callbacks
h=findobj(new);
name={'ButtonDownFcn','Callback','UIContextMenu'};
for n=1:numel(h)
    for m=1:numel(name)
        if isprop(h(n),name{m})
            set(h(n),name{m},'')
        end
    end
end

end