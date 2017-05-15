function saveData(fig,mode)

box=SMASH.MUI.Dialog();
box.Hidden=true;
switch mode
    case 'all' 
        box.Name='Save all digitizers';
    case 'current'
        box.Name='Save current digitizer';
        
end

%addblock(box,'text','Save format:');
choices={'Separate archives (*.sda)' 'Combined archive (*.sda)' 'Digitizer files (*.h5)'}; 
format=addblock(box,'popup','Save format:',choices,20);
set(format(1),'Fontweight','bold');

name=addblock(box,'edit','Base file name:',40);
set(name(1),'FontWeight','bold');

location=addblock(box,'edit_button',{'File location:' ' Select '},40);
set(location(1),'FontWeight','bold');
set(location(2),'String',pwd);
set(location(3),'Callback',@selectLocation)
    function selectLocation(varargin)
        start=get(location(2),'String');
        if ~exist(start,'dir')
            start=pwd;
        end
        name=uigetdir(start,'Select directory');
        if isnumeric(name)
            return
        end
        set(location(2),'String',name);
    end

values={'0 (none)' '1' '2' '3' '4' '5' '6' '7' '8' '9 (maximum)'};
deflate=addblock(box,'popup','Compression level:',values,20);
set(deflate(1),'Fontweight','bold');

button=addblock(box,'button',{' Save ' ' Cancel '});

movegui(box.Handle,'center');
box.Hidden=false;

% UNDER CONSTRUCTION

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