function saveData(fig,mode)

dig=getappdata(fig.Figure,'DigitizerObject');
switch lower(mode)
    case 'all'
        dig2file(dig,name);
    case 'current'
        
    case 'selected'
        
end

end