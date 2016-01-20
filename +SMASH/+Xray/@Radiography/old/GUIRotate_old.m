function obj_Rotate = GUIRotate(object,varargin)
% % % determine if GUI already exists

h=findall(0,'Type','figure','Tag','guiRotate');
if ishandle(h)
    figure(h);
    return
end


figRadiography=SMASH.MUI.Figure();
figRadiography.Name='Use Dialog Box to Rotate Image';

imagesc(object.Grid1,object.Grid2,object.Data);

diaRotate=SMASH.MUI.Dialog;
diaRotate.Hidden=true;
diaRotate.Name='Choose Rotation Angle';
set(diaRotate.Handle,'Tag','guiRotate');

hRcw=addblock(diaRotate,'button',' CW '); % button block
set(hRcw,'Callback',{@CWcallback,rad_Crop}); % button probes dialog state and closes it

hRccw=addblock(diaRotate,'button',' CCW '); % button block
set(hRccw,'Callback',@CCWcallback);

hARB=addblock(diaRotate,'edit',' Rotation Angle [-90,90] ',0); % button block
%set(hARB,'Callback',@RotCallback);

hRot=addblock(diaRotate,'button',' Update ');
set(hRot,'Callback',@RotCallback);

hRot=addblock(diaRotate,'button',' Done ');
set(hRot,'Callback',@DoneCallback);

diaRotate.Hidden=false;

end
function CWcallback(varargin)
object = rotate(object,'right');
imagesc(object.Grid1,object.Grid2,object.Data,'Parent',ax1);
end

function CCWcallback(varargin)
object = rotate(object,'left');
imagesc(object.Grid1,object.Grid2,object.Data,'Parent',ax1);

end

function RotCallback(varargin)
value=probe(diaRotate);
angle=sscanf(value{1},'%g');
object_new = rotate(object,angle);
imagesc(object_new.Grid1,object_new.Grid2,object_new.Data,'Parent',ax1);
end

function obj_Rotate = DoneCallback(varargin)
delete(diaRotate);
hData = findobj(gca,'Type','Image');
RData = get(hData,'CData');
xData = get(hData,'XData');
yData = get(hData,'YData');
obj_Rotate = SMASH.ImageAnalysis.Image(xData,yData,RData);
delete(figRadiography);
end


