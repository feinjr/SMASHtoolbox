function saveData(fig,mode)

box=SMASH.MUI.Dialog();
box.Hidden=true;
switch mode
    case 'all' 
        box.Name='Save all';
    case 'current'
        box.Name='Save current';
        
end

movegui(box.Handle,'center');
box.Hidden=false;

% base file name
while true
   name=inputdlg('Base archive name: ','Base name',[1 40]);
    if isempty(name)
        return
    end
    name=name{1};
    if isempty(name)
        continue
    end 
    name=strtrim(name);
    temp=fullfile(pwd,[name '.sda']);
    fid=fopen(temp,'w');
    if fid < 0
        errordlg('Invalid archive name','Invalid name');
        continue
    end
    fclose(fid);
    delete(temp);
    break
end

% determine submode and deflate
deflate=9;

% save data
dig=getappdata(fig.Figure,'DigitizerObject');
switch lower(mode)
    case 'all'
        dig2file(dig,name,deflate);
    case 'current'
        popup=getappdata(fig.ControlPanel,'DigitizerPopup');
        index=get(popup,'Value');
        dig2file(dig(index),name,deflate);        
end

end

function dig2file(dig,name,deflate)

for n=1:numel(dig)
    label=dig(n).Name;
    file=sprintf('%s_%s.sda',name,label);
    local=fullfile(pwd,file);
    description={};
    description{end+1}=sprintf('Measurement saved %s',datestr(now)); %#ok<AGROW>
    temp=dig.System;
    description{end+1}=sprintf('%s %s (%s)',...
        temp.Company,temp.ModelNumber,temp.SerialNumber); %#ok<AGROW>
    description=sprintf('%s\n',description{:});
    result=grab(dig(n));
    SMASH.FileAccess.writeFile(local,label,result,...
        description,deflate,'-overwrite');
end

end