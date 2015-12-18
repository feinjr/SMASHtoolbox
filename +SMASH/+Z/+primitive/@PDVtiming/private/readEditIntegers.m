function readEditIntegers(src,~)

value=get(src,'String');
try
    value=eval(sprintf('[%s]',value));
    assert(all(value==round(value)),'ERROR');    
    value=sprintf('%d ',value);
catch
    value=get(src,'UserData');
end
set(src,'String',value,'UserData',value);

end