function [coordinates,hRectangle]=DrawRectangle(varargin)
p=inputParser;
defaultPosition=[1,1,1,1];
addOptional(p,'RectPosition',defaultPosition,@isnumeric);
addOptional(p,'axes',gca);
parse(p,varargin{:});
position=p.Results.RectPosition;
ax=p.Results.axes;

k=0;
hRectangle=rectangle(ax,'Position',position,'EdgeColor','red','LineWidth',1.5,'LineStyle','-.');
point2=0;

while k==0
    if ishandle(ax)==0
        break
    end
    try
        k = waitforbuttonpress;
        CurrentPlot=get(gca,'Position');
        point1 = get(gca,'CurrentPoint');
        if point1(1,2)>ax.YLim(1) && point1(1,2)<ax.YLim(2) && ...
           point1(1,1)>ax.XLim(1) && point1(1,1)<ax.XLim(2) && ...
           point1(1)~=point2(1) && CurrentPlot(2)==ax.Position(2)
            rbbox;
            point2 = get(gca,'CurrentPoint');
            point1 = point1(1,1:2);
            point2 = point2(1,1:2);
            p1 = min(point1,point2);
            offset = abs(point1-point2);
            
            x1 = p1(1);
            x2 = p1(1)+offset(1);
            y1 = p1(2);
            y2 = p1(2)+offset(2);
            if y1>ax.YLim(1) && y2<ax.YLim(2) && x1>ax.XLim(1) && x2<ax.XLim(2)
                delete(hRectangle)
                hRectangle=rectangle(ax,'Position',[x1,y1,x2-x1,y2-y1],'EdgeColor','red','LineWidth',1.5,'LineStyle','-.');
                coordinates=round([y1,y2,x1,x2]);
            end
        end
        
    catch ME
        if strcmp(ME.identifier,'MATLAB:UI:CancelWaitForKeyOrButtonPress')
            close all
            break
        end
    end
end
end