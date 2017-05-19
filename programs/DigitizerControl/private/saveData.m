function saveData(fig,dig,BoxName,fontsize)

box=SMASH.MUI.Dialog('FontSize',fontsize);
box.Hidden=true;
box.Name=BoxName;

choices={'Digitizer files (*.h5)' 'Digitizer archives (*.sda)'}; 
format=addblock(box,'popup','Save format:',choices,20);
set(format(1),'Fontweight','bold');
set(format(2),'Callback',@changeFormat);
    function changeFormat(varargin)
        switch get(format(2),'Value')
            case 1               
                set(deflate(2),'Enable','off','String',{'N/A'});
            case 2
                set(deflate(2),'Enable','on','String',DeflateValues);
        end
    end

DeflateValues={'0 (none)' '1' '2' '3' '4' '5' '6' '7' '8' '9 (maximum)'};
deflate=addblock(box,'popup','Compression level:',DeflateValues,20);
set(deflate(1),'Fontweight','bold');
set(deflate(2),'Enable','off','String','N/A');

name=addblock(box,'edit_check',{'Base file name:' ' Overwrite '},40);
set(name(1),'FontWeight','bold');
set(name(2),'String','data','Callback',@editName);
    function editName(varargin)
        temp=strtrim(get(name(2),'String'));
        if isempty(temp)
            temp='data';
        end
        set(name(2),'String',temp);
    end

location=addblock(box,'edit_button',{'File location:' ' Select '},40);
set(location(1),'FontWeight','bold');
set(location(2),'String',pwd,'Callback',@editLocation);
    function editLocation(varargin)
        temp=strtrim(get(location(2),'String'));
        if ~exist(temp,'dir')
            temp=pwd;
        end
        set(location(2),'String',temp);
    end
set(location(3),'Callback',@selectLocation)
    function selectLocation(varargin)
        start=get(location(2),'String');
        if ~exist(start,'dir')
            start=pwd;
        end
        temp=uigetdir(start,'Select directory');
        if isnumeric(temp)
            return
        end
        set(location(2),'String',temp);
    end

button=addblock(box,'button',{' Save ' ' Close '});
set(button(1),'Callback',@saveDig)
    function saveDig(varargin) 
        % 
        temp=get(location(2),'String');
        if ~exist(temp,'dir')
            errmsg{1}='';
            errmsg{end+1}='Invalid save location';
            errmsg{end+1}='';
            errordlg(errmsg,'Invalid location');
            return
        end
        % save data
        clash=false;
        OriginalColor=get(button(1),'BackgroundColor');
        set(button(1),'BackgroundColor','m');
        drawnow();
        for n=1:numel(dig)
            switch get(format(2),'Value')
                case 1
                    save(dig(n));
                    ext='.h5';
                case 2
                    ext='.sda';
                    % UNDER CONSTRUCTION
            end
            old=[dig(n).Name ext];
            new=fullfile(get(location(2),'String'),[get(name(2),'String') old]);
            if get(name(3),'Value')               
                movefile(old,new,'f');               
            elseif exist(new,'file')
                clash=true;
                delete(old);
            else
                movefile(old,new);
            end
        end
        set(button(1),'Backgroundcolor',OriginalColor);
        if clash
            errstr{1}='';
            errstr{end+1}='File name clash detected';
            errstr{end+1}='Not all data could be saved';
            errstr{end+1}='Try a different base name or enable overwrite';
            errstr{end+1}='';
            errordlg(errstr,'Name clash');
        end
    end
set(button(2),'Callback',@closeBox);
    function closeBox(varargin)
        delete(box.Handle);
        figure(fig.Figure);
    end

movegui(box.Handle,'center');
box.Hidden=false;
box.Modal=true;

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