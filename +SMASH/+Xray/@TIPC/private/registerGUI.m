function [registered, shifts] = registerGUI( reference, moving, varargin )
%%
h=findall(0,'Type','figure','Tag','guiRegister');
if ishandle(h)
    figure(h);
    return
end
axespos=[0.0 0.0 1.0 1.0];

dx = reference.Grid1(2) - reference.Grid1(1);

%% Create MUI figure and show object
moving_crop = regrid(moving,reference.Grid1,reference.Grid2);
im_fused = fuse(reference.Data,moving_crop.Data);

h=basic_figure();
h.axes(1)=axes('Parent',h.panel,'OuterPosition',axespos,...
    'Tag','Fused Image','YDir','Normal',...
    'XLim',[reference.Grid1(1) , reference.Grid1(end)],...
    'YLim',[reference.Grid2(1) , reference.Grid2(end)]);
hold on
h.image(1)=imagesc(reference.Grid1,reference.Grid2,im_fused);
x0 = [0;0];
setappdata(h.figure,'Shifts',[]);
setappdata(h.figure,'Registered',[]);

set(h.figure,'WindowKeyPressFcn',@KeyPressCallback);
hbutton=uicontrol('Parent',h.figure,'Style','pushbutton','String',' Accept ',...
        'Callback','delete(gcbo)');
figure(h.figure);
set(hbutton,'Enable','on');

waitfor(hbutton)

registered = getappdata(h.figure, 'Registered');
shifts = getappdata(h.figure, 'Shifts');
delete(h.figure);

    function KeyPressCallback(~,eventdata)
        if strcmpi(eventdata.Key,'shift')
            return
        end
        if isempty(eventdata.Modifier)
            MoveImage(h,eventdata.Key, 1);
        elseif strcmpi(eventdata.Modifier,'shift')
            MoveImage(h,eventdata.Key, 0.5);
        end
    end
    function MoveImage(haxes,key, delta)
        switch lower(key)
            case 'leftarrow'
                xnew = [x0(1) - delta*dx; x0(2)];
            case 'rightarrow'
                xnew = [x0(1) + delta*dx; x0(2)];
            case 'downarrow'
                xnew = [x0(1); x0(2) - delta*dx];
            case 'uparrow'
                xnew = [x0(1); x0(2) + delta*dx];
        end
                
        mov = shift(moving,'Grid1',xnew(1));
        mov = shift(mov,'Grid2',xnew(2));
        movCrop = regrid(mov,reference.Grid1,reference.Grid2);
        
        imf = fuse(reference.Data,movCrop.Data);
        set(haxes.image(1),'XData',movCrop.Grid1,'YData',movCrop.Grid2,...
            'CData',imf);
        
        x0 = xnew;
        setappdata(h.figure,'Registered', movCrop);
        setappdata(h.figure,'Shifts', x0);
        
    end
end

