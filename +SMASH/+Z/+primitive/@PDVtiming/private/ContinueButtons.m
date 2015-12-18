function hb=ContinueButtons(gui)

hb(1)=addButton(gui,' Continue ');
set(hb(1),'Tag','keep');
hb(2)=addButton(gui,' Close/continue');
set(hb(2),'Tag','close');

set(hb,'Callback',@continueButton);
    function continueButton(src,varargin)
        switch get(src,'Tag')
            case 'keep'
                delete(hb);
            case 'close'
                delete(gui.Figure.Handle);
        end        
    end
end