function readTableDouble(src,eventdata)

data=get(src,'Data');
row=eventdata.Indices(1);
column=eventdata.Indices(2);

try
    value=eval(sprintf('[%s]',eventdata.EditData));
    assert(isnumeric(value) && isscalar(value),'ERROR');
    data{row,column}=sprintf('%.3f',value);
catch
    data{row,column}=eventdata.PreviousData;
end

set(src,'Data',data);

end