%This function takes image data as an input and rotates the image according
%to two points selected by the user. The image is rotated so that the
%selected points are horizontal.Once the image has been satisfactorily
%rotated the user can exit the GUI window, and the rotated image and angle
%will be returned.

%created May 12, 2017 by Sonal Patel (Sandia National Laboratories)

function [RotatedData,angle]=RotateSpectraGUI(image)
fh=figure;
%f=figure;
ax=axes;
ScaledImage(fh,ax,image);
title('Select 2 points to rotate image')
uicontrol(fh,'Style','pushbutton','String',{'Reset'},'Callback',{@ClickPoints}, 'Units','normalized','Position', [0.05, .95, 0.1, .05]);
uicontrol(fh,'Style','pushbutton','String',{'Rotate'},'Callback',{@ClickRotate}, 'Units','normalized','Position', [0.15, .95, 0.1, .05]);
xpoints=[0,0];
ypoints=[0,0];
ClickPoints
uiwait
    function ClickPoints(~,~)
        cla
        xpoints1=[];
        ypoints1=[];
        ax=gca;
        ScaledImage(fh,ax,image);
        for i=1:1:2   % read ginputs until a mouse right-button occurs
            [pointx,pointy] = ginput(1);
            hold on
            scatter(pointx,pointy,7,'r','filled')
            xpoints1(end+1)=pointx; %#ok<AGROW>
            ypoints1(end+1)=pointy; %#ok<AGROW>
        end
        xpoints=xpoints1;
        ypoints=ypoints1;
        hold on
        plot(xpoints,ypoints,'r')
    end
    function ClickRotate(~,~)
        cla
        height=ypoints(2)-ypoints(1);
        width=abs(xpoints(2)-xpoints(1));
        angle=atan(height/width);
        angle=rad2deg(angle);
        RotatedData=Rotate(image,angle);
        ax=gca;
        ScaledImage(fh,ax,RotatedData);
        grid on
    end
end