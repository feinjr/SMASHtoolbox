function WorkingButton(button)

if ~isappdata(button,'WorkingState')
    setappdata(button,'WorkingState','off');
    setappdata(button,'OriginalColor',get(button,'BackgroundColor'));
end

switch getappdata(button,'WorkingState')
    case 'off'
        set(button,'BackgroundColor','m');
        setappdata(button,'WorkingState','on');
    case 'on'
        set(button,'BackgroundColor',...
            getappdata(button,'OriginalColor'));
        setappdata(button,'WorkingState','off');
end

drawnow();

end