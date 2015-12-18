function readEditDouble(src,~)

value=get(src,'String');
try
    value=eval(sprintf('[%s]',value));
    assert(isnumeric(value) && isscalar(value),'ERROR');
    value=sprintf('%g',value);    
catch
    value=get(src,'UserData');
end
set(src,'String',value,'UserData',value);

end