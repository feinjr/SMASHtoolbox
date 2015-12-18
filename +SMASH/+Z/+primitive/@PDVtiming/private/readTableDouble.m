function readTableDouble(src,eventdata)

data=get(src,'Data');
row=eventdata.Indices(1);
column=eventdata.Indices(2);

value=sscanf(eventdata.EditData,'%g',1);
if numel(value)==1
    data{row,column}=sprintf('%.3f',value);
else    
    data{row,column}=eventdata.PreviousData;
end

set(src,'Data',data);

end