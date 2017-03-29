function [registered, shifts] = registerGUI( reference, moving, varargin )
%%
h=findall(0,'Type','figure','Tag','guiRegister');
if ishandle(h)
    figure(h);
    return
end

dx = reference.Grid1(2) - reference.Grid1(1);

%% Create MUI figure and show object
figRegister=SMASH.MUI.Figure('NumberTitle','off');
figRegister.Name='Fused image';
setappdata(figRegister.Handle,'obj_Register', []);
setappdata(figRegister.Handle,'Shifts', []);

moving_crop = regrid(moving,reference.Grid1,reference.Grid2);
im_fused = fuse(reference.Data,moving_crop.Data);
hView = imagesc(reference.Grid1,reference.Grid2,im_fused);
set(gca,'YDir', 'Normal');
hold on

%% Create Dialog box to manipulate image
diaShift=SMASH.MUI.Dialog;
diaShift.Hidden=true;
diaShift.Name='Interactive rotation';
set(diaShift.Handle,'Tag','guiRotate');

addblock(diaShift,'edit','Horizontal Shift (pixels):'); % Edit box to input rotation angle
addblock(diaShift,'edit','Vertical Shift (pixels):'); % Edit box to input rotation angle
hdl_Apply = addblock(diaShift,'button', {'Apply','Done'});
set(hdl_Apply(1),'Callback',@ApplyCallback);
set(hdl_Apply(2),'Callback',@DoneCallback);

diaShift.Hidden=false;
uiwait;

registered = getappdata(figRegister.Handle, 'obj_Register');
shifts = getappdata(figRegister.Handle, 'Shifts');

delete(figRegister);

    function ApplyCallback(varargin)
        value=probe(diaShift);
        if isempty(value{1})
            xShift = 0;
            yShift = str2double(value{2});
        elseif isempty(value{2})
            xShift = str2double(value{1});
            yShift = 0;
        else
            xShift = str2double(value{1});
            yShift = str2double(value{2});
        end        
        mov = shift(moving,'Grid1',xShift*dx);
        mov = shift(mov,'Grid2',yShift*dx);
        movCrop = regrid(mov,reference.Grid1,reference.Grid2);
        
        imf = fuse(reference.Data,movCrop.Data);
        set(hView,'XData',movCrop.Grid1,'YData',movCrop.Grid2,...
            'CData',imf);
    end


    function DoneCallback(varargin)
        value=probe(diaShift);
        if isempty(value{1})
            xShift = 0;
            yShift = str2double(value{2});
        elseif isempty(value{2})
            xShift = str2double(value{1});
            yShift = 0;
        else
            xShift = str2double(value{1});
            yShift = str2double(value{2});
        end        
        
        mov = shift(moving,'Grid1',xShift*dx);
        mov = shift(mov,'Grid2',yShift*dx);
        movCrop = regrid(mov,reference.Grid1,reference.Grid2);
        
        setappdata(figRegister.Handle,'obj_Register', movCrop);
        setappdata(figRegister.Handle,'Shifts', [xShift, yShift]);
        delete(diaShift);
    end


end

