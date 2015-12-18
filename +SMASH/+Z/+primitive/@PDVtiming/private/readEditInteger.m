function readEditInteger(src,~)

value=get(src,'String');
try
    value=sscanf(value,'%d');
    assert(isscalar(value),'ERROR');    
    value=sprintf('%d ',value);
catch
    value=get(src,'UserData');
end
set(src,'String',value,'UserData',value);

end